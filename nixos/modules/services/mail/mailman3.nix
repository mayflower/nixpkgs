{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.mailman;
  postfixConfigFile = pkgs.writeText "mailman-postfix.cfg" ''
    [postfix]
    postmap_command: ${pkgs.postfix}/bin/postmap
    transport_file_type: hash
  '';
  configFile = pkgs.writeText "mailman.cfg" ''
    # This is the absolute bare minimum base configuration file.  User supplied
    # configurations are pushed onto this.

    [mailman]
    # This address is the "site owner" address.  Certain messages which must be
    # delivered to a human, but which can't be delivered to a list owner (e.g. a
    # bounce from a list owner), will be sent to this address.  It should point to
    # a human.
    site_owner: root@yflower.de
    layout: here

    [mta]
    configuration: ${postfixConfigFile}

    [paths.here]
    # Everything in the same directory
    var_dir: /var/lib/mailman
    bin_dir: ${pkgs.mailman3}/bin

    [database]
    class: mailman.database.postgresql.PostgreSQLDatabase
    url: postgres:///mailman

    [archiver.hyperkitty]
    class: mailman_hyperkitty.Archiver
    enable: yes
    #configuration: /deployment/mailman-hyperkitty.cfg

    # [archiver.prototype]
    # enable: yes
  '';
in {
  options = {
    services.mailman = {
      enable = mkEnableOption "Whether to run the mailman3 daemon.";
    };
  };

  config = mkIf cfg.enable {
    users.extraUsers.mailman = {
      group = "mailman";
    };

    users.extraGroups.mailman = { };

    services.postgresql.enable = mkDefault true;

    systemd.tmpfiles.rules = [
      "d /var/lib/mailman 0775 mailman mailman -"
      "d /var/lib/mailman/postorius 0775 mailman mailman -"
      "d /run/mailman 0775 mailman mailman -"
    ];

    systemd.services.mailman = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      serviceConfig = {
        ExecStart = "${pkgs.mailman3}/bin/mailman -C ${configFile} start";
        Restart = "always";
        Type = "forking";
        User = "mailman";
        PermissionsStartOnly = true;
      };

      preStart = ''
        if ! test -e "/var/lib/mailman/db-created"; then
            ${pkgs.postgresql}/bin/createuser --no-superuser --no-createdb --no-createrole mailman
            ${pkgs.postgresql}/bin/createdb --owner mailman mailman
            touch "/var/lib/mailman/db-created"
        fi
      '';
    };

    systemd.sockets.mailman-postorius = {
      wantedBy = [ "sockets.target" ];
      listenStreams = [ "/run/mailman/postorius.socket" ];
    };
    systemd.services.mailman-postorius = let
      uwsgi = pkgs.uwsgi.override { plugins = [ "python3" ]; };
      configModule = pkgs.python3.pkgs.buildPythonPackage {
        name = "demockrazy-config";
        format = "other";
        unpackPhase = ":";
        installPhase = ''
          mkdir -p $out/${pkgs.python3.sitePackages}/postorius_config
          cat << "EOF" > $out/${pkgs.python3.sitePackages}/postorius_config/__init__.py
          from example_project.settings import *
          STATIC_ROOT = '/var/lib/mailman/postorius/static'
          DEBUG = False

          ALLOWED_HOSTS = [ 'lists.yflower.de' ]

          ROOT_URLCONF = 'example_project.urls'

          DATABASES = {
              'default': {
                  'ENGINE': 'django.db.backends.sqlite3',
                  'NAME': '/var/lib/mailman/postorius.sqlite3'
              }
          }

          LOGGING = {
              'version': 1,
              'disable_existing_loggers': False,
              'handlers': {
                  'console': {
                      'class': 'logging.StreamHandler',
                  },
              },
              'loggers': {
                  'django': {
                      'handlers': ['console'],
                      'level': 'DEBUG',
                  },
              },
          }
          EOF
        '';
      };
      env = uwsgi.python3.buildEnv.override {
        extraLibs = [ configModule pkgs.postorius ];
      };
      pythonPath = "${env}/${env.python.sitePackages}:${pkgs.postorius}/share/postorius";
      postoriusUwsgi = pkgs.writeText "uwsgi.json" (builtins.toJSON {
        uwsgi = {
          plugins = [ "python3" ];
          uid = "mailman";
          socket = "/run/mailman/postorius.socket";
          chown-socket = "mailman:nginx";
          chmod-socket = 770;
          chdir = "${pkgs.postorius}/share/postorius";
          wsgi-file = "example_project/wsgi.py";
          master = true;
          processes = 4;
          # stats = "/run/mailman/postorius-stats.socket";
          no-orphans = true;
          vacuum = true;
          logger = "syslog";
        };
      });
    in {
      description = "Postorius - Web UI for GNU Mailman";
      after = [ "network.target" ];
      requires = [ "mailman-postorius.socket" ];
      environment = {
        DJANGO_SETTINGS_MODULE = "postorius_config";
        PYTHONPATH = pythonPath;
      };
      preStart = ''
        cd ${pkgs.postorius}/share/postorius/example_project
        ${pkgs.sudo}/bin/sudo -u mailman -E PYTHONPATH=${pythonPath} ${env}/bin/python3 manage.py migrate
        ${pkgs.sudo}/bin/sudo -u mailman -E PYTHONPATH=${pythonPath} ${env}/bin/python3 manage.py collectstatic --noinput
      '';
      serviceConfig = {
        Type = "notify";
        Restart = "on-failure";
        KillSignal = "SIGQUIT";
        StandardError = "syslog";
        NotifyAccess = "all";
        ExecStart = "${uwsgi}/bin/uwsgi --json ${postoriusUwsgi}";
        PrivateTmp = "yes";
      };
    };
  };
}

