{ config, lib, pkgs, ... }:

let
  inherit (builtins) readFile toString;
  inherit (lib) attrsets generators modules options strings types;
  inherit (attrsets) mapAttrsToList recursiveUpdate;
  inherit (generators) toINI;
  inherit (modules) mkIf;
  inherit (options) literalExpression mdDoc mkEnableOption mkOption;
  inherit (strings) concatStrings replaceStrings;

  cfg = config.services.hagrid;
  toml = pkgs.formats.toml {};
  defaultSettings = {
    global = {
      address = "127.0.0.1";
      port = 8080;
    };
    release = {
      assets_dir = "${cfg.webRoot}/assets";
      base-URI = "https://${cfg.hostname}";
      base-URI-Onion = "https://${cfg.hostname}";
      email_template_dir = "${cfg.dataDir}/email-templates";
      enable_prometheus = false;
      from = "noreply@localhost";
      keys_external_dir = "${cfg.webRoot}/keys";
      keys_internal_dir = "${cfg.dataDir}/keys";
      mail_rate_limit = 3600;
      maintenance_file = "${cfg.dataDir}/maintenance";
      template_dir = "${cfg.dataDir}/templates";
      tmp_dir = "${cfg.dataDir}/tmp";
      token_dir = "${cfg.dataDir}/tokens";
      token_secret = "$TOKEN_SECRET";
      token_validity = 3600;
      x-accel-redirect = true;
    };
  };
in {
  meta.maintainers = with lib.maintainers; [ ];

  options = {

    services.hagrid = {

      enable = mkEnableOption (mdDoc ''
        hagrid (Verifying OpenPGP keyserver, written in Rust)'');

      package = mkOption {
        default = pkgs.hagrid;
        defaultText = literalExpression "pkgs.hagrid";
        type = types.package;
        description = mdDoc "Which hagrid derivation to use.";
      };

      dataDir = mkOption {
        type = types.path;
        default = "/var/lib/hagrid";
        example = "/var/db/hagrid";
        description = mdDoc ''
          Data directory for hagrid, where the keys, assets,
          templates and Rocket.toml are located.
        '';
      };

      environmentFile = mkOption {
        type = types.path;
        description = mdDoc ''
          Systemd EnvironmentFile with secrets to inject
          into the service config before startup.
        '';
      };

      hostname = mkOption {
        type = types.str;
        description = mdDoc ''
          Which hostname to set the vHost to that is proxying to hagrid.
        '';
      };

      settings = mkOption {
        type = toml.type;
        default = defaultSettings;
        apply = settings: recursiveUpdate defaultSettings settings;
        description = mdDoc ''
          Configuration for hagrid rocket server in toml type (attrset).
          See https://gitlab.com/keys.openpgp.org/hagrid/ for details.
        '';
      };

      webRoot = mkOption {
        type = types.path;
        default = "${cfg.dataDir}/public";
        readOnly = true;
      };

    };
  };

  config = mkIf cfg.enable {

    users = {
      users.hagrid = {
        isSystemUser = true;
        description = "hagrid user";
        home = cfg.dataDir;
        createHome = true;
        group = "hagrid";
        useDefaultShell = true;
        packages = [ cfg.package ];
      };
      groups.hagrid = { };
    };

    systemd.services = let
      releaseProfile = cfg.settings.release;
      dirMap = {
        assets = releaseProfile.assets_dir;
        templates = releaseProfile.template_dir;
        email-templates = releaseProfile.email_template_dir;
        #errors-static = cfg.webRoot + "/errors-static";
      };
    in {
      hagrid = {
        description = "hagrid (Verifying OpenPGP keyserver)";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];
        preStart = ''
          ${concatStrings (mapAttrsToList (name: path: ''
            mkdir -p $(dirname ${path})
            test -L ${path} && rm ${path}
            ln -s ${cfg.package}/dist/${name} ${path}
          '') dirMap)}

          rm -f "${cfg.dataDir}/Rocket.toml"

          ${pkgs.envsubst}/bin/envsubst \
            -o "${cfg.dataDir}/Rocket.toml" \
            -i "${toml.generate "Rocket.toml" cfg.settings}"
        '';
        serviceConfig = {
          WorkingDirectory = "~";
          User = "hagrid";
          Group = "hagrid";
          Restart = "always";
          ExecStart = "${cfg.package}/bin/hagrid";
          EnvironmentFile = cfg.environmentFile;
        };
      };
    };

    services.nginx.enable = true;
    services.nginx.virtualHosts = let
      address = cfg.settings.global.address;
      port = cfg.settings.global.port;
    in {
      ${cfg.hostname} = {
        root = cfg.webRoot;
        locations."/" = {
          proxyPass = "http://${address}:${toString port}";
        };
      };
    };

  };
}
