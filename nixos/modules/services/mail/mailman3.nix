{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.mailman;
  python = pkgs.python3;
  mailmanEnv = python.withPackages (ps: [ pkgs.mailman3 ps.mailman-hyperkitty ]);
  postfixConfigFile = pkgs.writeText "mailman-postfix.cfg" ''
    [postfix]
    postmap_command: ${pkgs.postfix}/bin/postmap
    transport_file_type: hash
  '';
  hyperkittyConfigFile = pkgs.writeText "mailman-hyperkitty.cfg" ''
    [general]

    # This is your HyperKitty installation, preferably on the localhost. This
    # address will be used by Mailman to forward incoming emails to HyperKitty
    # for archiving. It does not need to be publicly available, in fact it's
    # better if it is not.
    base_url: https://lists.yflower.de/hyperkitty/

    # Shared API key, must be the identical to the value in HyperKitty's
    # settings.
    api_key: SecretArchiverAPIKey
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
    bin_dir: ${mailmanEnv}/bin

    [database]
    class: mailman.database.postgresql.PostgreSQLDatabase
    url: postgres:///mailman

    [archiver.hyperkitty]
    class: mailman_hyperkitty.Archiver
    enable: yes
    configuration: ${hyperkittyConfigFile}

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
      "d /var/lib/mailman/web 0775 mailman mailman -"
      "d /run/mailman 0775 mailman mailman -"
    ];

    systemd.services.mailman = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      serviceConfig = {
        ExecStart = "${mailmanEnv}/bin/mailman -C ${configFile} start";
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

    systemd.sockets.mailman-web = {
      wantedBy = [ "sockets.target" ];
      listenStreams = [ "/run/mailman/web.socket" ];
    };
    systemd.services.mailman-web = let
      uwsgi = pkgs.uwsgi.override { plugins = [ "python3" ]; };
      configModule = python.pkgs.buildPythonPackage {
        name = "mailman-web-config";
        format = "other";
        unpackPhase = ":";
        installPhase = ''
          mkdir -p $out/${python.sitePackages}/mailman_web_config
          cat << "EOF" > $out/${python.sitePackages}/mailman_web_config/__init__.py
          from example_project.settings import *
          BASE_DIR = '/var/lib/mailman/web'
          STATIC_ROOT = '/var/lib/mailman/web/static'
          SECRET_KEY = 'FIXME-change-this-on-your-production-server'
          DEBUG = False

          ALLOWED_HOSTS = [ '::1', '127.0.0.1', 'localhost', 'lists.yflower.de' ]

          ROOT_URLCONF = 'mailman_web_config.urls'

          MAILMAN_REST_API_URL = 'http://localhost:8001'
          MAILMAN_REST_API_USER = 'restadmin'
          MAILMAN_REST_API_PASS = 'restpass'
          MAILMAN_ARCHIVER_KEY = 'SecretArchiverAPIKey'
          MAILMAN_ARCHIVER_FROM = ('127.0.0.1', '::1', '2a01:4f8:10a:b0e::1')

          INSTALLED_APPS = (
            'hyperkitty',
            'postorius',
            'rest_framework',
            'paintstore',
            'compressor',
            'haystack',
            'django_extensions',
            'django_q',
            'django.contrib.admin',
            'django.contrib.auth',
            'django.contrib.contenttypes',
            'django.contrib.sessions',
            'django.contrib.sites',
            'django.contrib.messages',
            'django.contrib.staticfiles',
            'django_mailman3',
            'django_gravatar',
            'allauth',
            'allauth.account',
            'allauth.socialaccount',
            'allauth.socialaccount.providers.openid',
            'django_mailman3.lib.auth.fedora',
            'allauth.socialaccount.providers.github',
            'allauth.socialaccount.providers.gitlab',
            'allauth.socialaccount.providers.google',
            #'allauth.socialaccount.providers.facebook',
            'allauth.socialaccount.providers.twitter',
            'allauth.socialaccount.providers.stackexchange',
          )

          MIDDLEWARE_CLASSES += ('django_mailman3.middleware.TimezoneMiddleware',)
          TEMPLATES[0]['OPTIONS']['context_processors'].append('hyperkitty.context_processors.common')

          DATABASES = {
              'default': {
                  'ENGINE': 'django.db.backends.sqlite3',
                  'NAME': '/var/lib/mailman/postorius.sqlite3'
              }
          }

          STATICFILES_FINDERS = (
              'django.contrib.staticfiles.finders.FileSystemFinder',
              'django.contrib.staticfiles.finders.AppDirectoriesFinder',
              # 'django.contrib.staticfiles.finders.DefaultStorageFinder',
              'compressor.finders.CompressorFinder',
          )

          SOCIALACCOUNT_PROVIDERS = {}

          COMPRESS_PRECOMPILERS = (
             ('text/x-scss', 'sassc -t compressed {infile} {outfile}'),
             ('text/x-sass', 'sassc -t compressed {infile} {outfile}'),
          )
          COMPRESS_OFFLINE = True

          HAYSTACK_CONNECTIONS = {
              'default': {
                  'ENGINE': 'haystack.backends.whoosh_backend.WhooshEngine',
                  'PATH': os.path.join(BASE_DIR, "fulltext_index"),
                  # You can also use the Xapian engine, it's faster and more accurate,
                  # but requires another library.
                  # http://django-haystack.readthedocs.io/en/v2.4.1/installing_search_engines.html#xapian
                  # Example configuration for Xapian:
                  #'ENGINE': 'xapian_backend.XapianEngine'
              },
          }

          REST_FRAMEWORK = {
              'PAGE_SIZE': 10,
              'DEFAULT_FILTER_BACKENDS': (
                  'rest_framework.filters.OrderingFilter',
              ),
          }

          Q_CLUSTER = {
              'timeout': 300,
              'save_limit': 100,
              'orm': 'default',
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

          FILTER_VHOST = False
          EOF
          install -v ${pkgs.postorius}/share/postorius/example_project/urls.py $out/${python.sitePackages}/mailman_web_config/urls.py
          sed -i "\$i url(r'^hyperkitty/', include('hyperkitty.urls'))," $out/${python.sitePackages}/mailman_web_config/urls.py
        '';
      };
      env = uwsgi.python3.withPackages (ps: [ configModule pkgs.postorius pkgs.hyperkitty ]);
      pythonPath = "${env}/${env.python.sitePackages}:${pkgs.postorius}/share/postorius";
      mailmanUwsgi = pkgs.writeText "uwsgi.json" (builtins.toJSON {
        uwsgi = {
          plugins = [ "python3" ];
          uid = "mailman";
          socket = "/run/mailman/web.socket";
          chown-socket = "mailman:nginx";
          chmod-socket = 770;
          chdir = "${pkgs.postorius}/share/postorius";
          wsgi-file = "example_project/wsgi.py";
          master = true;
          processes = 4;
          # stats = "/run/mailman/web-stats.socket";
          no-orphans = true;
          vacuum = true;
          logger = "syslog";
        };
      });
    in {
      description = "Web UI and archiver for GNU Mailman";
      after = [ "network.target" ];
      requires = [ "mailman-web.socket" ];
      path = [ pkgs.sassc ];
      environment = {
        DJANGO_SETTINGS_MODULE = "mailman_web_config";
        PYTHONPATH = pythonPath;
      };
      preStart = ''
        cd ${pkgs.postorius}/share/postorius/example_project
        ${pkgs.sudo}/bin/sudo -u mailman -E PYTHONPATH=${pythonPath} ${env}/bin/python manage.py migrate
        ${pkgs.sudo}/bin/sudo -u mailman -E PYTHONPATH=${pythonPath} ${env}/bin/python manage.py compress
        ${pkgs.sudo}/bin/sudo -u mailman -E PYTHONPATH=${pythonPath} ${env}/bin/python manage.py collectstatic --noinput
      '';
      serviceConfig = {
        Type = "notify";
        Restart = "on-failure";
        KillSignal = "SIGQUIT";
        StandardError = "syslog";
        NotifyAccess = "all";
        ExecStart = "${uwsgi}/bin/uwsgi --json ${mailmanUwsgi}";
        PrivateTmp = "yes";
      };
    };
  };
}

