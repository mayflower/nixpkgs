{ config, lib, ... }:

with lib;

let
  cfg = config.services.unifi-poller;

  configFile = pkgs.writeText "up.json" (generators.toJSON {} {
    inherit (cfg) poller influxdb prometheus;
    unifi = {
      inherit (cfg.unifi) dynamic defaults;
      controllers = map (flip removeAttrs [ "_module" ]) cfg.unifi.controllers;
    };
  });

in {
  options.services.unifi-poller = {
    enable = mkEnableOption "unifi-poller";

    poller = {
      debug = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Turns on line numbers, microsecond logging, and a per-device log.
          This may be noisy if you have a lot of devices. It adds one line per device.
        '';
      };
      quiet = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Turns off per-interval logs. Only startup and error logs will be emitted.
        '';
      };
      plugins = mkOption {
        type = with types; listOf str;
        default = [];
        description = ''
          Load additional plugins.
        '';
      };
    };

    prometheus = {
      disable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to disable the prometheus ouput plugin.
        '';
      };
      http_listen = mkOption {
        type = types.str;
        default = "0.0.0.0:9130";
        description = ''
          Bind the prometheus exporter to this IP or hostname.
        '';
      };
      report_errors = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to report errors.
        '';
      };
    };

    influxdb = {
      disable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to disable the influxdb ouput plugin.
        '';
      };
      url = mkOption {
        type = types.str;
        default = "http://127.0.0.1:8086";
        description = ''
          URL of the influxdb host.
        '';
      };
      user = mkOption {
        type = types.str;
        default = "unifipoller";
        description = ''
          Username for the influxdb.
        '';
      };
      pass = mkOption {
        type = types.str;
        default = "unifipoller";
        description = ''
          Password for the influxdb.
        '';
      };
      db = mkOption {
        type = types.str;
        default = "unifi";
        description = ''
          Database name. Database should exist.
        '';
      };
      verify_ssl = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Verify the influxdb's certificate.
        '';
      };
      interval = mkOption {
        type = types.str;
        default = "30s";
        description = ''
          Setting this lower than the Unifi controller's refresh
          interval may lead to zeroes in your database.
        '';
      };
    };

    unifi = let
      controllerOptions = {
        user = mkOption {
          type = types.str;
          default = "unifi";
          description = ''
            Unifi service user name.
          '';
        };
        pass = mkOption {
          type = types.str;
          default = "unifi";
          description = ''
            Unifi service user password.
            If prefixed with "file://" the password will be read from the given file.
          '';
        };
        url = mkOption {
          type = types.str;
          default = "https://unifi:8443";
          description = ''
            URL of the Unifi controller.
          '';
        };
        sites = mkOption {
          type = with types; listOf (oneOf [ (enum [ "default" "all" ]) str ]);
          default = [ "all" ];
          description = ''
            List of site names or "default" or "all".
          '';
        };
        save_ids = mkOption {
          type = types.bool;
          default = false;
          description = ''
            Collect and save data from the intrusion detection system to influxdb.
          '';
        };
        save_dpi = mkOption {
          type = types.bool;
          default = false;
          description = ''
            Collect and save data from deep packet inspection.
            Adds around 150 data points and impacts performance.
          '';
        };
        save_sites = mkOption {
          type = types.bool;
          default = true;
          description = ''
            Collect and save site data.
          '';
        };
        hash_pii = mkOption {
          type = types.bool;
          default = false;
          description = ''
            Hash, with md5, client names and MAC addresses. This attempts
            to protect personally identifiable information.
          '';
        };
        verify_ssl = mkOption {
          type = types.bool;
          default = false;
          description = ''
            Verify the Unifi controller's certificate.
          '';
        };
      };

    in {
      dynamic = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Let prometheus select which controller to poll when scraping.
          Use with default credentials. See wiki for more.
        '';
      };

      defaults = controllerOptions;

      controllers = mkOption {
        type = with types; listOf (submodule { options = controllerOptions; });
        default = [];
        description = ''
          List of Unifi controllers to poll. Use defaults if empty.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.unifi-poller = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      serviceConfig = {
        Restart = "always";
        PrivateTmp = true;
        WorkingDirectory = /tmp;
        DynamicUser = true;
        ExecStart = "${pkgs.unifi-poller}/bin/unifi-poller --config ${configFile}";
      };
    };
  };
}
