{ config, lib, pkgs }:

with lib;

let
  cfg = config.services.prometheus.exporters.mail;
in
{
  port = 9225;
  extraOpts = {
     configFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = ''
        Specify the mailexporter configuration file to use.
      '';
    };
  };
  serviceOpts = {
    serviceConfig = {
      ExecStart = ''
        ${pkgs.prometheus-mail-exporter}/bin/mailexporter \
          --web.listen-address ${cfg.listenAddress}:${toString cfg.port} \
          --config.file ${cfg.configFile} \
          ${concatStringsSep " \\\n  " cfg.extraFlags}
      '';
    };
  };
}
