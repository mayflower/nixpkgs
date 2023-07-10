{ config, pkgs, lib, ... }:
let
  cfg = config.services.meshcentral;
  configFormat = pkgs.formats.json {};
  configFile = configFormat.generate "meshcentral-config.json" cfg.settings;
  gatherSecrets = prefix: lib.foldlAttrs
    (acc: k: v:
      let path = prefix ++ [ k ]; in
      acc ++ (if lib.isAttrs v then gatherSecrets path v else lib.singleton {
        inherit path;
        id = lib.concatStrings path;
        filepath = v;
      }))
    [ ];
  secretsToLoad = gatherSecrets [ ] cfg.secrets;
in with lib; {
  options.services.meshcentral = with types; {
    enable = mkEnableOption (lib.mdDoc "MeshCentral computer management server");
    package = mkOption {
      description = lib.mdDoc "MeshCentral package to use. Replacing this may be necessary to add dependencies for extra functionality.";
      type = types.package;
      default = pkgs.meshcentral;
      defaultText = literalExpression "pkgs.meshcentral";
    };
    secrets = mkOption {
      type = types.submodule {
        freeformType = let t = with types; attrsOf (oneOf [ t str ]); in t // { description = "injectable secrets"; };
      };
      example = literalExpression ''
        {
          domains."".authStrategies.oidc.clientsecret = "/path/to/oidc-client-secret";
        }
      '';
      description = lib.mdDoc ''
        Secrets in the same JSON schema as the config itself. The values are paths to secret-files.
        The _content_ of the file is being injected into the JSON path of the configuration file.
        I.e. in the example, `domains."".authStrategies.oidc.clientsecret` in the final configfile would
        have the value of `/path/to/oidc-client-secret`.
      '';
    };
    settings = mkOption {
      description = lib.mdDoc ''
        Settings for MeshCentral. Refer to upstream documentation for details:

        - [JSON Schema definition](https://github.com/Ylianst/MeshCentral/blob/master/meshcentral-config-schema.json)
        - [simple sample configuration](https://github.com/Ylianst/MeshCentral/blob/master/sample-config.json)
        - [complex sample configuration](https://github.com/Ylianst/MeshCentral/blob/master/sample-config-advanced.json)
        - [Old homepage with documentation link](https://www.meshcommander.com/meshcentral2)
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
  config = mkIf cfg.enable {
    services.meshcentral.settings = lib.mkMerge ([
      { settings.autoBackup.backupPath = lib.mkDefault "/var/lib/meshcentral/backups"; }
    ] ++ lib.forEach secretsToLoad ({ id, path, ... }: lib.setAttrByPath path "@secret_${id}@"));
    systemd.services.meshcentral = {
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        ExecStart = "${cfg.package}/bin/meshcentral --datapath /var/lib/meshcentral --configfile /var/lib/meshcentral/meshcentral-config.json";
        ExecStartPre = "${pkgs.writeShellScript "meshcentral-init-secrets" ''
          cp -v "${configFile}" ''${STATE_DIRECTORY}/meshcentral-config.json
          chmod u+w ''${STATE_DIRECTORY}/meshcentral-config.json
          ${lib.concatMapStrings ({ id, ... }: ''
            ${pkgs.replace-secret}/bin/replace-secret \
              '@secret_${id}@' \
              ''${CREDENTIALS_DIRECTORY}/${id} \
              ''${STATE_DIRECTORY}/meshcentral-config.json
          '') secretsToLoad}
        ''}";
        DynamicUser = true;
        StateDirectory = "meshcentral";
        CacheDirectory = "meshcentral";
        LoadCredential = map ({ id, filepath, ... }: "${id}:${filepath}") secretsToLoad;
      };
    };
  };
  meta.maintainers = [ maintainers.lheckemann ];
}
