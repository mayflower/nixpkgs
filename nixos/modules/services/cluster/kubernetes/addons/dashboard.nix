{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.services.kubernetes.addons.dashboard;
in {
  options.services.kubernetes.addons.dashboard = {
    enable = mkEnableOption "kubernetes dashboard addon";

    rbac = mkOption {
      description = "Role-based access control (RBAC) options";
      default = {};
      type = types.submodule {
        options = {
          enable = mkOption {
            description = "Whether to enable role based access control is enabled for kubernetes dashboard";
            type = types.bool;
            default = elem "RBAC" config.services.kubernetes.apiserver.authorizationMode;
          };

          clusterAdmin = mkOption {
            description = "Whether to assign cluster admin rights to the kubernetes dashboard";
            type = types.bool;
            default = false;
          };
        };
      };
    };

    version = mkOption {
      description = "Which version of the kubernetes dashboard to deploy";
      type = types.str;
      default = "v1.8.3";
    };

    image = mkOption {
      description = "Docker image to seed for the kubernetes dashboard container.";
      type = types.attrs;
      default = {
        imageName = "k8s.gcr.io/kubernetes-dashboard-amd64";
        imageDigest = "sha256:dc4026c1b595435ef5527ca598e1e9c4343076926d7d62b365c44831395adbd0";
        finalImageTag = cfg.version;
        sha256 = "18ajcg0q1vignfjk2sm4xj4wzphfz8wah69ps8dklqfvv0164mc8";
      };
    };
  };

  config = mkIf cfg.enable {
    services.kubernetes.kubelet.seedDockerImages = [(pkgs.dockerTools.pullImage cfg.image)];

    services.kubernetes.addonManager.addons = let
      l = f: builtins.fromJSON (builtins.readFile f);
    in {
      kubernetes-dashboard-deployment = let
        deployment = l ./dashboard/deployment-kubernetes-dashboard.json;
      in lib.recursiveUpdate deployment {
        metadata = {
          labels = {
            k8s-addon = "kubernetes-dashboard.addons.k8s.io";
            version = cfg.version;
          };
        };
        spec = {
          replicas = 1;
          revisionHistoryLimit = 10;
          template = {
            metadata = {
              labels = {
                k8s-addon = "kubernetes-dashboard.addons.k8s.io";
                version = cfg.version;
                "kubernetes.io/cluster-service" = "true";
              };
            };
            spec = {
              containers = map (container:
                if "kubernetes-dashboard" == container.name
                then lib.recursiveUpdate container {
                  image = with cfg.image; "${imageName}:${finalImageTag}";
                  resources = {
                    requests = {
                      cpu = "100m";
                    };
                   };
                }
                else container
              ) deployment.spec.template.spec.containers;
              tolerations = deployment.spec.template.spec.tolerations ++ [{
                key = "node-role.kubernetes.io/master";
                effect = "NoSchedule";
              }];
            };
          };
        };
      };

      kubernetes-dashboard-svc = let
        service = l ./dashboard/service-kubernetes-dashboard.json;
      in lib.recursiveUpdate service {
        metadata = {
          labels = {
            k8s-addon = "kubernetes-dashboard.addons.k8s.io";
            "kubernetes.io/name" = "KubeDashboard";
          };
        };
      };

      kubernetes-dashboard-sa = let
        account = l ./dashboard/serviceaccount-kubernetes-dashboard.json;
      in lib.recursiveUpdate account {
        metadata = {
          labels = {
            k8s-addon = "kubernetes-dashboard.addons.k8s.io";
          };
        };
      };

      kubernetes-dashboard-sec-certs = l ./dashboard/secret-kubernetes-dashboard-certs.json;
      kubernetes-dashboard-sec-kholder = l ./dashboard/secret-kubernetes-dashboard-key-holder.json;
      kubernetes-dashboard-cm = l ./dashboard/configmap-kubernetes-dashboard-settings.json;
    } // (optionalAttrs cfg.rbac.enable
      (if cfg.rbac.clusterAdmin then {
        kubernetes-dashboard-crb = {
          apiVersion = "rbac.authorization.k8s.io/v1";
          kind = "ClusterRoleBinding";
          metadata = {
            name = "kubernetes-dashboard";
            labels = {
              k8s-app = "kubernetes-dashboard";
              k8s-addon = "kubernetes-dashboard.addons.k8s.io";
              "addonmanager.kubernetes.io/mode" = "Reconcile";
            };
          };
          roleRef = {
            apiGroup = "rbac.authorization.k8s.io";
            kind = "ClusterRole";
            name = "cluster-admin";
          };
          subjects = [{
            kind = "ServiceAccount";
            name = "kubernetes-dashboard";
            namespace = "kube-system";
          }];
        };
      }
      else
      {
        kubernetes-dashboard-role = let
          role = l ./dashboard/role-kubernetes-dashboard-minimal.json;
        in lib.recursiveUpdate role {
          metadata.labels.k8s-addon = "kubernetes-dashboard.addons.k8s.io";
        };

        kubernetes-dashboard-rb = let
          binding = l ./dashboard/rolebinding-kubernetes-dashboard-minimal.json;
        in lib.recursiveUpdate binding {
          metadata.labels.k8s-addon = "kubernetes-dashboard.addons.k8s.io";
        };
      })
    );
  };
}
