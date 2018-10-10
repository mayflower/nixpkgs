{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.privacyidea;

  logCfg = pkgs.writeText "privacyidea-log.cfg" ''
    [formatters]
    keys=detail

    [handlers]
    keys=stream

    [formatter_detail]
    class=privacyidea.lib.log.SecureFormatter
    format=[%(asctime)s][%(process)d][%(thread)d][%(levelname)s][%(name)s:%(lineno)d] %(message)s

    [handler_stream]
    class=StreamHandler
    level=NOTSET
    formatter=detail
    args=(sys.stdout,)

    [loggers]
    keys=root,privacyidea

    [logger_privacyidea]
    handlers=stream
    qualname=privacyidea
    level=INFO

    [logger_root]
    handlers=stream
    level=ERROR
  '';

  piCfgFile = pkgs.writeText "privacyidea.cfg" ''
    SUPERUSER_REALM = [ '${concatStringsSep "', '" cfg.superuserRealm}' ]
    SQLALCHEMY_DATABASE_URI = '${cfg.databaseURI}'
    SECRET_KEY = '${cfg.secretKey}'
    PI_PEPPER = '${cfg.pepper}'
    PI_ENCFILE = '${cfg.encFile}'
    PI_AUDIT_KEY_PRIVATE = '${cfg.auditKeyPrivate}'
    PI_AUDIT_KEY_PUBLIC = '${cfg.auditKeyPublic}'
    PI_LOGCONFIG = '${logCfg}'
    ${cfg.extraConfig}
  '';

in

{
  options = {
    services.privacyidea = {
      enable = mkEnableOption "PrivacyIDEA";

      stateDir = mkOption {
        type = types.str;
        default = "/var/lib/privacyidea";
        description = ''
          Directory where all PrivacyIDEA files will be placed by default.
        '';
      };

      runDir = mkOption {
        type = types.str;
        default = "/run/privacyidea";
        description = ''
          Directory where all PrivacyIDEA files will be placed by default.
        '';
      };

      superuserRealm = mkOption {
        type = types.listOf types.str;
        default = [ "super" "administrators" ];
        description = ''
          The realm where users are allowed to login as administrators.
        '';
      };

      databaseURI = mkOption {
        type = types.str;
        default = "postgresql:///privacyidea";
        description = ''
          Database as SQLAlchemy URI to use for PrivacyIDEA.
        '';
      };

      secretKey = mkOption {
        type = types.str;
        example = "t0p s3cr3t";
        description = ''
          This is used to encrypt the auth_token.
        '';
      };

      pepper = mkOption {
        type = types.str;
        example = "Never know...";
        description = ''
          This is used to encrypt the admin passwords.
        '';
      };

      encFile = mkOption {
        type = types.str;
        default = "${cfg.stateDir}/enckey";
        description = ''
          This is used to encrypt the token data and token passwords
        '';
      };

      auditKeyPrivate = mkOption {
        type = types.str;
        default = "${cfg.stateDir}/private.pem";
        description = ''
          Private Key for signing the audit log.
        '';
      };

      auditKeyPublic = mkOption {
        type = types.str;
        default = "${cfg.stateDir}/public.pem";
        description = ''
          Public key for checking signatures of the audit log.
        '';
      };

      adminPassword = mkOption {
        type = types.str;
        description = "Password for the admin user";
      };

      adminEmail = mkOption {
        type = types.str;
        example = "admin@example.com";
        description = "Mail address for the admin user";
      };

      extraConfig = mkOption {
        type = types.lines;
        default = "";
        description = ''
          Extra configuration options for pi.cfg.
        '';
      };

      user = mkOption {
        type = types.str;
        default = "privacyidea";
        description = "User account under which PrivacyIDEA runs.";
      };

      group = mkOption {
        type = types.str;
        default = "privacyidea";
        description = "Group account under which PrivacyIDEA runs.";
      };

      ldap-proxy = {
        enable = mkEnableOption "PrivacyIDEA LDAP Proxy";

        configFile = mkOption {
          type = types.path;
          default = "";
          description = ''
            Path to PrivacyIDEA LDAP Proxy configuration (proxy.ini).
          '';
        };

        user = mkOption {
          type = types.str;
          default = "pi-ldap-proxy";
          description = "User account under which PrivacyIDEA LDAP proxy runs.";
        };

        group = mkOption {
          type = types.str;
          default = "pi-ldap-proxy";
          description = "Group account under which PrivacyIDEA LDAP proxy runs.";
        };
      };
    };
  };

  config = mkMerge [

    (mkIf cfg.enable {

      environment.systemPackages = [ pkgs.privacyidea ];

      services.postgresql.enable = mkDefault true;

      systemd.services.privacyidea = let
        uwsgi = pkgs.uwsgi.override { plugins = [ "python2" ]; };
        penv = uwsgi.python2.buildEnv.override {
          extraLibs = [ pkgs.privacyidea ];
        };
        piuwsgi = pkgs.writeText "uwsgi.json" (builtins.toJSON {
          uwsgi = {
            plugins = [ "python2" ];
            pythonpath = "${penv}/${uwsgi.python2.sitePackages}";
            socket = "${cfg.runDir}/socket";
            uid = cfg.user;
            gid = cfg.group;
            chmod-socket = 770;
            chown-socket = "${cfg.user}:nginx";
            chdir = cfg.stateDir;
            wsgi-file = "${pkgs.privacyidea}/etc/privacyidea/privacyideaapp.wsgi";
            processes = 4;
            harakiri = 60;
            reload-mercy = 8;
            stats = "${cfg.runDir}/stats.socket";
            max-requests = 2000;
            limit-as = 1024;
            reload-on-as = 512;
            reload-on-rss = 256;
            no-orphans = true;
            vacuum = true;
            pyargv = piCfgFile;
          };
        });
      in {
        wantedBy = [ "multi-user.target" ];
        after = [ "postgresql.service" ];
        path = with pkgs; [ openssl ];
        preStart = let
          pi-manage = "${pkgs.sudo}/bin/sudo -u privacyidea -H PRIVACYIDEA_CONFIGFILE=${piCfgFile} ${pkgs.privacyidea}/bin/pi-manage";
        in ''
          mkdir -p ${cfg.stateDir} ${cfg.runDir}
          chown ${cfg.user}:${cfg.group} -R ${cfg.stateDir} ${cfg.runDir}
          if ! test -e "${cfg.stateDir}/db-created"; then
            ${pkgs.sudo}/bin/sudo ${pkgs.postgresql}/bin/createuser --no-superuser --no-createdb --no-createrole ${cfg.user}
            ${pkgs.sudo}/bin/sudo ${pkgs.postgresql}/bin/createdb --owner ${cfg.user} privacyidea
            ${pi-manage} create_enckey
            ${pi-manage} create_audit_keys
            ${pi-manage} createdb
            ${pi-manage} admin add admin -e ${cfg.adminEmail} -p ${cfg.adminPassword}
            touch "${cfg.stateDir}/db-created"
            chmod g+r "${cfg.stateDir}/enckey" "${cfg.stateDir}/private.pem"
          fi
        '';
        serviceConfig = {
          Type = "notify";
          ExecStart = "${uwsgi}/bin/uwsgi --json ${piuwsgi}";
          ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
          ExecStop = "${pkgs.coreutils}/bin/kill -INT $MAINPID";
          NotifyAccess = "main";
          KillSignal = "SIGQUIT";
          StandardError = "syslog";
        };
      };

      users.extraUsers = optionalAttrs (cfg.user == "privacyidea")
        (singleton
          { name = cfg.user;
            group = cfg.group;
          });

      users.extraGroups = optionalAttrs (cfg.group == "privacyidea")
        (singleton { name = cfg.group; });
    })

    (mkIf cfg.ldap-proxy.enable {

      systemd.services.privacyidea-ldap-proxy = let pkg = pkgs.privacyidea-ldap-proxy; in {
        description = "privacyIDEA LDAP proxy";
        wantedBy = [ "multi-user.target" ];
        environment.PYTHONPATH = "${pkg}/${pkg.python.sitePackages}:${pkg.env}/${pkg.python.sitePackages}";
        serviceConfig = {
          User = cfg.ldap-proxy.user;
          Group = cfg.ldap-proxy.group;
          ExecStart = ''
            ${pkg.env}/bin/twistd \
              --nodaemon \
              --pidfile= \
              -u ${cfg.ldap-proxy.user} \
              -g ${cfg.ldap-proxy.group} \
              ldap-proxy \
              -c ${cfg.ldap-proxy.configFile}
          '';
          Restart = "always";
        };
      };

      users.extraUsers = optionalAttrs (cfg.ldap-proxy.user == "pi-ldap-proxy")
        (singleton
          { name = cfg.ldap-proxy.user;
            group = cfg.ldap-proxy.group;
          });

      users.extraGroups = optionalAttrs (cfg.ldap-proxy.group == "pi-ldap-proxy")
        (singleton { name = cfg.ldap-proxy.group; });

    })
  ];

}
