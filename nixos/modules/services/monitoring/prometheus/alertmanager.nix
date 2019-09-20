{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.services.prometheus.alertmanager;
  mkConfigFile = pkgs.writeText "alertmanager.yml" (builtins.toJSON cfg.configuration);

  checkedConfig = file: pkgs.runCommand "checked-config" { buildInputs = [ cfg.package ]; } ''
    ln -s ${file} $out
    amtool check-config $out
  '';

  alertmanagerYml = let
    yml = if cfg.configText != null then
        pkgs.writeText "alertmanager.yml" cfg.configText
        else mkConfigFile;
    in checkedConfig yml;

  cmdlineArgs = cfg.extraFlags ++ [
    "--config.file ${alertmanagerYml}"
    "--web.listen-address ${cfg.listenAddress}:${toString cfg.port}"
    "--log.level ${cfg.logLevel}"
    "--storage.path ${cfg.stateDir}"
    (toString (map (peer: "--cluster.peer ${peer}:9094") cfg.clusterPeers))
    ] ++ (optional (cfg.webExternalUrl != null)
      "--web.external-url ${cfg.webExternalUrl}"
    ) ++ (optional (cfg.logFormat != null)
      "--log.format ${cfg.logFormat}"
  );
in {
  options = {
    services.prometheus.alertmanager = {
      enable = mkEnableOption "Prometheus Alertmanager";

      package = mkOption {
        type = types.package;
        default = pkgs.prometheus-alertmanager;
        defaultText = "pkgs.alertmanager";
        description = ''
          Package that should be used for alertmanager.
        '';
      };

      configuration = mkOption {
        type = types.nullOr types.attrs;
        default = null;
        description = ''
          Alertmanager configuration as nix attribute set.
        '';
      };

      configText = mkOption {
        type = types.nullOr types.lines;
        default = null;
        description = ''
          Alertmanager configuration as YAML text. If non-null, this option
          defines the text that is written to alertmanager.yml. If null, the
          contents of alertmanager.yml is generated from the structured config
          options.
        '';
      };

      logFormat = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          If set use a syslog logger or JSON logging.
        '';
      };

      logLevel = mkOption {
        type = types.enum ["debug" "info" "warn" "error" "fatal"];
        default = "warn";
        description = ''
          Only log messages with the given severity or above.
        '';
      };

      webExternalUrl = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          The URL under which Alertmanager is externally reachable (for example, if Alertmanager is served via a reverse proxy).
          Used for generating relative and absolute links back to Alertmanager itself.
          If the URL has a path portion, it will be used to prefix all HTTP endoints served by Alertmanager.
          If omitted, relevant URL components will be derived automatically.
        '';
      };

      listenAddress = mkOption {
        type = types.str;
        default = "";
        description = ''
          Address to listen on for the web interface and API. Empty string will listen on all interfaces.
          "localhost" will listen on 127.0.0.1 (but not ::1).
        '';
      };

      port = mkOption {
        type = types.int;
        default = 9093;
        description = ''
          Port to listen on for the web interface and API.
        '';
      };

      openFirewall = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Open port in firewall for incoming connections.
        '';
      };

      clusterPeers = mkOption {
        type = types.listOf types.str;
        default = [];
        description = ''
          Initial peers for HA cluster.
        '';
      };

      extraFlags = mkOption {
        type = types.listOf types.str;
        default = [];
        description = ''
          Extra commandline options when launching the Alertmanager.
        '';
      };
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      assertions = singleton {
        assertion = cfg.configuration != null || cfg.configText != null;
        message = "Can not enable alertmanager without a configuration. "
         + "Set either the `configuration` or `configText` attribute.";
      };
    })
    (mkIf cfg.enable {
      networking.firewall.allowedTCPPorts = optional cfg.openFirewall cfg.port;

      users.extraUsers."${cfg.user}".group = cfg.group;
      users.extraGroups."${cfg.group}" = { };

      systemd.tmpfiles.rules = [
        "d ${cfg.stateDir} 0770 ${cfg.user} ${cfg.group} -"
      ];

      systemd.services.alertmanager = {
        wantedBy = [ "multi-user.target" ];
        after    = [ "network.target" ];
        serviceConfig = {
          Restart  = "always";
          DynamicUser = true;
          WorkingDirectory = "/tmp";
          ExecStart = "${cfg.package}/bin/alertmanager" +
            optionalString (length cmdlineArgs != 0) (" \\\n  " +
              concatStringsSep " \\\n  " cmdlineArgs);
          ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
        };
      };
    })
  ];
}
