{ config, lib, pkgs, ... }:

with lib;

let
  top = config.services.kubernetes;
  cfg = top.addonManager;

  isRBACEnabled = elem "RBAC" top.apiserver.authorizationMode;

  addons = pkgs.runCommand "kubernetes-addons" { } ''
    mkdir -p $out
    # since we are mounting the addons to the addon manager, they need to be copied
    ${concatMapStringsSep ";" (a: "cp -v ${a}/* $out/") (mapAttrsToList (name: addon:
      pkgs.writeTextDir "${name}.json" (builtins.toJSON addon)
    ) (cfg.addons))}
  '';
in
{
  ###### interface
  options.services.kubernetes.addonManager = with lib.types; {

    bootstrapAddons = mkOption {
      description = ''
        Bootstrap addons are like regular addons, but they are applied with cluster-admin rigths.
        They are applied at addon-manager startup only.
      '';
      default = { };
      type = attrsOf attrs;
      example = literalExample ''
        {
          "my-service" = {
            "apiVersion" = "v1";
            "kind" = "Service";
            "metadata" = {
              "name" = "my-service";
              "namespace" = "default";
            };
            "spec" = { ... };
          };
        }
      '';
    };

    addons = mkOption {
      description = "Kubernetes addons (any kind of Kubernetes resource can be an addon).";
      default = { };
      type = attrsOf (either attrs (listOf attrs));
      example = literalExample ''
        {
          "my-service" = {
            "apiVersion" = "v1";
            "kind" = "Service";
            "metadata" = {
              "name" = "my-service";
              "namespace" = "default";
            };
            "spec" = { ... };
          };
        }
        // import <nixpkgs/nixos/modules/services/cluster/kubernetes/dashboard.nix> { cfg = config.services.kubernetes; };
      '';
    };

    enable = mkEnableOption "Whether to enable Kubernetes addon manager.";
  };

  ###### implementation
  config = mkIf cfg.enable {
    environment.etc."kubernetes/addons".source = "${addons}/";

    systemd.services.kube-addon-manager = {
      description = "Kubernetes addon manager";
      wantedBy = [ "kube-control-plane-online.target" ];
      after = [ "kube-addon-manager-bootstrap.service" ];
      before = [ "kube-control-plane-online.target" ];
      environment.ADDON_PATH = "/etc/kubernetes/addons/";
      path = [ pkgs.gawk ];
      preStart = ''
        ${top.lib.mkWaitCurl ( with config.systemd.services.kube-addon-manager; {
          path = "/api/v1/namespaces/kube-system/serviceaccounts/default";
          cacert = top.caFile;
        } // optionalAttrs (environment ? cert) { inherit (environment) cert key; })}
      '';
      serviceConfig = {
        Slice = "kubernetes.slice";
        ExecStart = "${top.package}/bin/kube-addons";
        WorkingDirectory = top.dataDir;
        User = "kubernetes";
        Group = "kubernetes";
        Restart = "on-failure";
        RestartSec = 10;
      };
    };

    systemd.services.kube-addon-manager-bootstrap = mkIf (top.apiserver.enable && top.addonManager.bootstrapAddons != {}) {
      wantedBy = [ "kube-control-plane-online.target" ];
      after = [ "kube-apiserver.service" ];
      before = [ "kube-control-plane-online.target" ];
      path = [ pkgs.kubectl ];
      preStart = with pkgs; let
        files = mapAttrsToList (n: v: writeText "${n}.json" (builtins.toJSON v))
          cfg.bootstrapAddons;
      in ''
        ${top.lib.mkWaitCurl ( with config.systemd.services.kube-addon-manager-bootstrap; {
          path = "/api";
          cacert = top.caFile;
        } // optionalAttrs (environment ? cert) { inherit (environment) cert key; })}

        kubectl apply -f ${concatStringsSep " \\\n -f " files}
      '';
      script = "echo Ok";
    };

    services.kubernetes.addonManager.bootstrapAddons = mkIf isRBACEnabled
    (let
      name = system:kube-addon-manager;
      namespace = "kube-system";
    in
    {

      kube-addon-manager-r = {
        apiVersion = "rbac.authorization.k8s.io/v1";
        kind = "Role";
        metadata = {
          inherit name namespace;
        };
        rules = [{
          apiGroups = ["*"];
          resources = ["*"];
          verbs = ["*"];
        }];
      };

      kube-addon-manager-rb = {
        apiVersion = "rbac.authorization.k8s.io/v1";
        kind = "RoleBinding";
        metadata = {
          inherit name namespace;
        };
        roleRef = {
          apiGroup = "rbac.authorization.k8s.io";
          kind = "Role";
          inherit name;
        };
        subjects = [{
          apiGroup = "rbac.authorization.k8s.io";
          kind = "User";
          inherit name;
        }];
      };

      kube-addon-manager-cluster-lister-cr = {
        apiVersion = "rbac.authorization.k8s.io/v1";
        kind = "ClusterRole";
        metadata = {
          name = "${name}:cluster-lister";
        };
        rules = [{
          apiGroups = ["*"];
          resources = ["*"];
          verbs = ["list"];
        }];
      };

      kube-addon-manager-cluster-lister-crb = {
        apiVersion = "rbac.authorization.k8s.io/v1";
        kind = "ClusterRoleBinding";
        metadata = {
          name = "${name}:cluster-lister";
        };
        roleRef = {
          apiGroup = "rbac.authorization.k8s.io";
          kind = "ClusterRole";
          name = "${name}:cluster-lister";
        };
        subjects = [{
          kind = "User";
          inherit name;
        }];
      };
    });

    services.kubernetes.pki.certs = {
      addonManager = top.lib.mkCert {
        name = "kube-addon-manager";
        CN = "system:kube-addon-manager";
        action = "systemctl restart kube-addon-manager.service";
      };
    };
  };

}
