{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.grocy;
in {
  options.services.grocy = {
    enable = mkEnableOption "grocy";

    hostName = mkOption {
      type = types.str;
      description = ''
        FQDN for the grocy instance.
      '';
    };

    nginx.enableSSL = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Whether or not to enable SSL (with ACME and let's encrypt)
        for the grocy vhost.
      '';
    };

    phpfpm.settings = mkOption {
      type = with types; attrsOf (oneOf [ int str bool ]);
      default = {
        "pm" = "dynamic";
        "php_admin_value[error_log]" = "stderr";
        "php_admin_flag[log_errors]" = true;
        "listen.owner" = "nginx";
        "catch_workers_output" = true;
        "pm.max_children" = "32";
        "pm.start_servers" = "2";
        "pm.min_spare_servers" = "2";
        "pm.max_spare_servers" = "4";
        "pm.max_requests" = "500";
      };

      description = ''
        Options for grocy's PHPFPM pool.
      '';
    };

    dataDir = mkOption {
      type = types.str;
      default = "/var/lib/grocy";
      description = ''
        Home directory of the <literal>grocy</literal> user which contains
        the application's state.
      '';
    };

    settings = {
      currency = mkOption {
        type = types.str;
        default = "USD";
        example = "EUR";
        description = ''
          ISO 4217 code for the currency to display.
        '';
      };

      culture = mkOption {
        type = types.enum [ "de" "en" "da" "en_GB" "es" "fr" "hu" "it" "nl" "no" "pl" "pt_BR" "ru" "sk_SK" "sv_SE" "tr" ];
        default = "en";
        description = ''
          Display language of the frontend.
        '';
      };

      calendar = {
        showWeekNumber = mkOption {
          default = true;
          type = types.bool;
          description = ''
            Show the number of the weeks in the calendar views.
          '';
        };
        firstDayOfWeek = mkOption {
          default = null;
          type = types.nullOr (types.enum (range 0 6));
          description = ''
            Which day of the week (0=Sunday, 1=Monday etc.) should be the
            first day.
          '';
        };
      };

      authClass = mkOption {
        default = "Grocy\\Middleware\\DefaultAuthMiddleware";
        example = "Grocy\\Middleware\\LdapAuthMiddleware";
        type = types.str;
        description = ''
          PHP class to use to process logins.
        '';
      };


      ldap = {
        address = mkOption {
          default = "";
          example = "ldap://example.com";
          type = types.str;
          description = ''
            URL of the LDAP server.
          '';
        };
        baseDN = mkOption {
          default = "";
          example = "ou=users,dc=example,dc=com";
          type = types.str;
          description = ''
            Base DN of the LDAP users.
          '';
        };
        bindDN = mkOption {
          default = "";
          example = "uid=grocy,ou=services,dc=example,dc=com";
          type = types.str;
          description = ''
            DN of the LDAP bind user.
          '';
        };
        bindPasswordFile = mkOption {
          default = "";
          type = types.str;
          description = ''
            Path to file with password of the LDAP bind user.
          '';
        };
        userFilter = mkOption {
          default = "";
          type = types.str;
          description = ''
            Filter applied to LDAP users for login.
          '';
        };
        uidAttr = mkOption {
          default = "uid";
          type = types.str;
          description = ''
            LDAP attribute to be used for user lookup.
          '';
        };
      };
    };
  };

  config = mkIf cfg.enable {
    environment.etc."grocy/config.php".text = ''
      <?php
      function nix_read_secret($file) {
        if (!file_exists($file)) {
          throw new \RuntimeException(sprintf(
            "Cannot start grocy, secret file %s set by NixOS doesn't seem to "
            . "exist! Please make sure that the file exists and has appropriate "
            . "permissions for user 'grocy'!",
            $file
          ));
        }

        return trim(file_get_contents($file));
      }

      Setting('CULTURE', '${cfg.settings.culture}');
      Setting('CURRENCY', '${cfg.settings.currency}');
      Setting('CALENDAR_FIRST_DAY_OF_WEEK', '${toString cfg.settings.calendar.firstDayOfWeek}');
      Setting('CALENDAR_SHOW_WEEK_OF_YEAR', ${boolToString cfg.settings.calendar.showWeekNumber});
      Setting('AUTH_CLASS', '${cfg.settings.authClass}');
      Setting('LDAP_ADDRESS', '${cfg.settings.ldap.address}');
      Setting('LDAP_BASE_DN', '${cfg.settings.ldap.baseDN}');
      Setting('LDAP_BIND_DN', '${cfg.settings.ldap.bindDN}');
      Setting('LDAP_BIND_PW', nix_read_secret('${cfg.settings.ldap.bindPasswordFile}'));
      Setting('LDAP_USER_FILTER', '${cfg.settings.ldap.userFilter}');
      Setting('LDAP_UID_ATTR', '${cfg.settings.ldap.uidAttr}');
    '';

    users.users.grocy = {
      isSystemUser = true;
      createHome = true;
      home = cfg.dataDir;
      group = "nginx";
    };

    systemd.tmpfiles.rules = map (
      dirName: "d '${cfg.dataDir}/${dirName}' - grocy nginx - -"
    ) [ "viewcache" "plugins" "settingoverrides" "storage" ];

    services.phpfpm.pools.grocy = {
      user = "grocy";
      group = "nginx";

      # PHP 7.4 is the only version which is supported/tested by upstream:
      # https://github.com/grocy/grocy/blob/v3.0.0/README.md#how-to-install
      phpPackage = pkgs.php74;

      inherit (cfg.phpfpm) settings;

      phpEnv = {
        GROCY_CONFIG_FILE = "/etc/grocy/config.php";
        GROCY_DB_FILE = "${cfg.dataDir}/grocy.db";
        GROCY_STORAGE_DIR = "${cfg.dataDir}/storage";
        GROCY_PLUGIN_DIR = "${cfg.dataDir}/plugins";
        GROCY_CACHE_DIR = "${cfg.dataDir}/viewcache";
      };
    };

    services.nginx = {
      enable = true;
      virtualHosts."${cfg.hostName}" = mkMerge [
        { root = "${pkgs.grocy}/public";
          locations."/".extraConfig = ''
            rewrite ^ /index.php;
          '';
          locations."~ \\.php$".extraConfig = ''
            fastcgi_split_path_info ^(.+\.php)(/.+)$;
            fastcgi_pass unix:${config.services.phpfpm.pools.grocy.socket};
            include ${config.services.nginx.package}/conf/fastcgi.conf;
            include ${config.services.nginx.package}/conf/fastcgi_params;
          '';
          locations."~ \\.(js|css|ttf|woff2?|png|jpe?g|svg)$".extraConfig = ''
            add_header Cache-Control "public, max-age=15778463";
            add_header X-Content-Type-Options nosniff;
            add_header X-XSS-Protection "1; mode=block";
            add_header X-Robots-Tag none;
            add_header X-Download-Options noopen;
            add_header X-Permitted-Cross-Domain-Policies none;
            add_header Referrer-Policy no-referrer;
            access_log off;
          '';
          extraConfig = ''
            try_files $uri /index.php;
          '';
        }
        (mkIf cfg.nginx.enableSSL {
          enableACME = true;
          forceSSL = true;
        })
      ];
    };
  };

  meta = {
    maintainers = with maintainers; [ ma27 ];
    doc = ./grocy.xml;
  };
}
