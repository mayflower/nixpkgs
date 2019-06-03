{ config, lib, pkgs }:

with lib;

let
  cfg = config.services.prometheus.exporters.unifi;
in
{
  port = 9130;
  extraOpts = {
    unifiAddress = mkOption {
      type = types.str;
      example = "https://10.0.0.1:8443";
      description = ''
        URL of the UniFi Controller API.
      '';
    };

    unifiInsecure = mkOption {
      type = types.bool;
      default = false;
      description = ''
        If enabled skip the verification of the TLS certificate of the UniFi Controller API.
        Use with caution.
      '';
    };

    unifiUsername = mkOption {
      type = types.str;
      example = "ReadOnlyUser";
      description = ''
        username for authentication against UniFi Controller API.
      '';
    };

    unifiPassword = mkOption {
      type = types.str;
      description = ''
        Password for authentication against UniFi Controller API.
      '';
    };

    unifiTimeout = mkOption {
      type = types.str;
      default = "5s";
      example = "2m";
      description = ''
        Timeout including unit for UniFi Controller API requests.
      '';
    };
  };
  serviceOpts = {
    serviceConfig = {
      DynamicUser = true;
      ExecStart = ''
        ${pkgs.prometheus-unifi-exporter}/bin/unifi_exporter \
          -config.file ${pkgs.writeText "unifi-exporter-config.yml"
          (builtins.toJSON {
            listen = { address = "${cfg.listenAddress}:${builtins.toString cfg.port}"; metricspath = "/metrics"; };
            unifi = {
              address = cfg.unifiAddress;
              username = cfg.unifiUsername;
              password = cfg.unifiPassword;
              insecure = if cfg.unifiInsecure then "true" else "false";
              timeout = cfg.unifiTimeout;
            };
          })} \
          ${concatStringsSep " \\\n  " cfg.extraFlags}
      '';
    };
  };
}
