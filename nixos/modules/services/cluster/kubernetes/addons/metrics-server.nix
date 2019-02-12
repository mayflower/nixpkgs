{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.services.kubernetes.addons.metrics-server;
in {
  options.services.kubernetes.addons.metrics-server = {
    enable = mkEnableOption "kubernetes metrics-server addon";

    rbac = mkOption {
      description = "Role-based access control (RBAC) options";
      default = {};
      type = types.submodule {
        options = {
          enable = mkOption {
            description = "Whether to enable role based access control is enabled for kubernetes metrics-server";
            type = types.bool;
            default = elem "RBAC" config.services.kubernetes.apiserver.authorizationMode;
          };

          clusterAdmin = mkOption {
            description = "Whether to assign cluster admin rights to the kubernetes metrics-server";
            type = types.bool;
            default = false;
          };
        };
      };
    };

    version = mkOption {
      description = "Which version of the kubernetes metrics-server to deploy";
      type = types.str;
      default = "v0.3.1";
    };

    image = mkOption {
      description = "Docker image to seed for the kubernetes metrics-server container.";
      type = types.attrs;
      default = {
        imageName = "k8s.gcr.io/metrics-server-amd64";
        imageDigest = "sha256:6f4a027083d92fd0f28d1aca83364e376e440625ca9a403f1d2d50adaa298d88";
        finalImageTag = cfg.version;
        sha256 = "1zil221z088dmpibxycjv9v8wg2vj15k6dbvqxv7zn9w5lajwn2d";
      };
    };
  };

  config = mkIf cfg.enable {
    services.kubernetes.kubelet.seedDockerImages = [(pkgs.dockerTools.pullImage cfg.image)];

    services.kubernetes.addonManager.addons = let
      l = f: builtins.fromJSON (builtins.readFile f);
    in {
      metrics-server-as = l ./metrics-server/apiservice-v1beta1.metrics.k8s.io.json;
      metrics-server-deployment = let
        json = l ./metrics-server/deployment-metrics-server-v0.3.1.json;
        fix-command = container:
          if container.name == "metrics-server" then
            container // {
              command = [
                "/metrics-server"
                "--metric-resolution=30s"
                "--kubelet-port=10255"
              ];
            }
          else container;
      in lib.recursiveUpdate json {
        spec.template.spec.containers = map fix-command json.spec.template.spec.containers;
      };
      metrics-server-svc = l ./metrics-server/service-metrics-server.json;
      metrics-server-sa = l ./metrics-server/serviceaccount-metrics-server.json;
      #metrics-server-sec-certs = {};
      #metrics-server-sec-kholder = {};
      metrics-server-cm = l ./metrics-server/configmap-metrics-server-config.json;

    } // (optionalAttrs cfg.rbac.enable
      (if cfg.rbac.clusterAdmin then {
        metrics-server-cr = l ./metrics-server/clusterrole-system-metrics-server.json;
        metrics-server-crb = l ./metrics-server/clusterrolebinding-system-metrics-server.json;
      }
      else
      {
        metrics-server-rb = l ./metrics-server/rolebinding-metrics-server-auth-reader.json;
        metrics-server-crb = l ./metrics-server/clusterrolebinding-metrics-server-system-auth-delegator.json;
      })
    );
  };
}
