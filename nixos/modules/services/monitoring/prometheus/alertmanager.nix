{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.services.alertmanager;
  mkConfigFile = pkgs.writeText "alertmanager.yml" cfg.configuration;
in {
  options = {
    services.alertmanager = {
      enable = mkEnableOption "Prometheus Alertmanager";

      user = mkOption {
        type = types.str;
        default = "root";
        description = ''
          Username under which Alertmanager shall be run.
        '';
      };

      group = mkOption {
        type = types.str;
        default = "root";
        description = ''
          Group under which Alertmanager shall be run.
        '';
      };

      configuration = mkOption {
        type = types.str;
        default = "";
        description = ''
          Alertmanager configuration.
        '';
      };

      logFormat = mkOption {
        type = types.str;
        default = "";
        description = ''
          If set use a syslog logger or JSON logging.
        '';
      };

      logLevel = mkOption {
        type = types.str;
        default = "warn";
        description = ''
    	    Only log messages with the given severity or above. Valid levels: [debug, info, warn, error, fatal].
        '';
      };

      webExternalUrl = mkOption {
        type = types.str;
        default = "";
        description = ''
    	    The URL under which Alertmanager is externally reachable (for example, if Alertmanager is served via a reverse proxy).
          Used for generating relative and absolute links back to Alertmanager itself.
          If the URL has a path portion, it will be used to prefix all HTTP endoints served by Alertmanager.
          If omitted, relevant URL components will be derived automatically.
        '';
      };

      webListenAddress = mkOption {
        type = types.str;
        default = "";
        description = ''
          Address to listen on for the web interface and API.
        '';
      };

      webListenPort = mkOption {
        type = types.int;
        default = 9093;
        description = ''
          Port to listen on for the web interface and API. (default "9093")
        '';
      };
    };
  };


  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [ cfg.port ];
    systemd.services.alertmanager = {
      wantedBy = [ "multi-user.target" ];
      after    = [ "network.target" ];
      script = ''
        ${pkgs.prometheus-alertmanager.bin}/bin/alertmanager \
        -config.file ${mkConfigFile} \
        -web.listen-address ${cfg.webListenAddress}:${toString cfg.webListenPort} \
        -log.level ${cfg.logLevel} \
        ${optionalString (cfg.webExternalUrl != "") ''-web.external-url ${cfg.webExternalUrl} \''}
        ${optionalString (cfg.logFormat != "") "-log.format ${cfg.logFormat}"}
      '';

      serviceConfig = {
        User = "${cfg.user}";
        Group = "${cfg.group}";
        Restart  = "always";
        PrivateTmp = true;
        WorkingDirectory = /tmp;
      };
    };
  };
}
