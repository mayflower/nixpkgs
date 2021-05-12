{ config, lib, pkgs, options }:

with lib;

let
  cfg = config.services.prometheus.exporters.unbound;
  unboundCfg = config.services.unbound;
in
{
  port = 9167;
  extraOpts = {
    fetchType = mkOption {
      # TODO: add shm when upstream implemented it
      type = types.enum [ "tcp" "uds" ];
      default = "uds";
      description = ''
        Which methods the exporter uses to get the information from unbound.
      '';
    };

    telemetryPath = mkOption {
      type = types.str;
      default = "/metrics";
      description = ''
        Path under which to expose metrics.
      '';
    };

    controlInterface = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "/run/unbound/unbound.socket";
      description = ''
        Path to the unbound socket for uds mode or the control interface port for tcp mode.

        Example:
          uds-mode: /run/unbound/unbound.socket
          tcp-mode: 127.0.0.1:8953
      '';
    };
  };

  serviceOpts = mkMerge ([{
    serviceConfig = {
      ExecStart = ''
        ${pkgs.prometheus-unbound-exporter}/bin/unbound-telemetry \
          ${cfg.fetchType} \
          --bind ${cfg.listenAddress}:${toString cfg.port} \
          --path ${cfg.telemetryPath} \
          ${optionalString (cfg.controlInterface != null) "--control-interface ${cfg.controlInterface}"} \
          ${toString cfg.extraFlags}
      '';
    };
  }] ++ [
    (mkIf unboundCfg.enable {
      after = [ "unbound.service" ];
      serviceConfig.SupplementaryGroups = mkIf (cfg.fetchType == "uds" && unboundCfg.localControlSocketPath != null) [ "unbound" ];
    })
  ]);
}
