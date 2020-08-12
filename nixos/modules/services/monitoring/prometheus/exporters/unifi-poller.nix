{ config, lib, pkgs, options }:

with lib;

let
  cfg = config.services.prometheus.exporters.unifi-poller;

  configFile = pkgs.writeText "up.json" (generators.toJSON {} {
    poller = {
      debug = cfg.debug;
      quiet = !cfg.debug;
    };
    influxdb.disable = true;
    prometheus = {
      http_listen = "${cfg.listenAddress}:${toString cfg.port}";
      report_errors = cfg.debug;
    };
    unifi = {
      inherit (cfg) dynamic defaults;
      controllers = map (flip removeAttrs [ "_module" ]) cfg.controllers;
    };
  });

in {
  port = 9130;

  extraOpts = options.services.unifi-poller.unifi // {
    debug = mkEnableOption "debugging output, also error reporting via prometheus.";
  };

  serviceOpts.serviceConfig.ExecStart = "${pkgs.unifi-poller}/bin/unifi-poller --config ${configFile}";
}
