{ config, pkgs, lib, ... }:
let
  cfg = config.services.meshcentral;
  configFormat = pkgs.formats.json {};
  configFile = configFormat.generate "meshcentral-config.json" cfg.settings;
in with lib; {
  options.services.meshcentral = with types; {
    enable = mkEnableOption "MeshCentral computer management server";
    package = mkOption {
      description = "MeshCentral package to use. Replacing this may be necessary to add dependencies for extra functionality.";
      type = types.package;
      default = pkgs.meshcentral;
      defaultText = "pkgs.meshcentral";
    };
    settings = mkOption {
      description = ''
        Settings for MeshCentral. Refer to upstream documentation for details:

        - [https://github.com/Ylianst/MeshCentral/blob/master/meshcentral-config-schema.json](JSON Schema definition)
        - [https://github.com/Ylianst/MeshCentral/blob/master/sample-config.json](simple sample configuration)
        - [https://github.com/Ylianst/MeshCentral/blob/master/sample-config-advanced.json](complex sample configuration)
        - [https://www.meshcommander.com/meshcentral2](Old homepage) with documentation links
      '';
      type = types.submodule {
        freeformType = configFormat.type;
      };
      example = {
        settings = {
          WANonly = true;
          Cert = "meshcentral.example.com";
          TlsOffload = "10.0.0.2,fd42::2";
          Port = 4430;
        };
        domains."".certUrl = "https://meshcentral.example.com/";
      };
    };
  };
  config.systemd.services.meshcentral = mkIf cfg.enable {
    wantedBy = ["multi-user.target"];
    path = [ cfg.package ];
    script = ''
      meshcentral --datapath $STATE_DIRECTORY --configfile ${configFile}
    '';
    serviceConfig = {
      DynamicUser = true;
      StateDirectory = "meshcentral";
      CacheDirectory = "meshcentral";
    };
  };
  meta.maintainers = [ maintainers.lheckemann ];
}
