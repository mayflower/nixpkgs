{ config, lib, pkgs, ... }:

with lib;

let
  top = config.services.kubernetes;
  cfg = top.flannel;

  # we want flannel to use kubernetes itself as configuration backend, not direct etcd
  storageBackend = "kubernetes";

  # needed for flannel to pass options to docker
  mkDockerOpts = pkgs.runCommand "mk-docker-opts" {
    buildInputs = [ pkgs.makeWrapper ];
  } ''
    mkdir -p $out
    cp ${pkgs.kubernetes.src}/cluster/centos/node/bin/mk-docker-opts.sh $out/mk-docker-opts.sh

    # bashInteractive needed for `compgen`
    makeWrapper ${pkgs.bashInteractive}/bin/bash $out/mk-docker-opts --add-flags "$out/mk-docker-opts.sh"
  '';
in
{
  ###### interface
  options.services.kubernetes.flannel = {
    enable = mkEnableOption "enable flannel networking";
    kubeconfig = top.lib.mkKubeConfigOptions "Kubernetes flannel";
  };

  ###### implementation
  config = let

    flannelPaths = filter (a: a != null) [
      cfg.kubeconfig.caFile
      cfg.kubeconfig.certFile
      cfg.kubeconfig.keyFile
    ];
    kubeconfig = top.lib.mkKubeConfig "flannel" cfg.kubeconfig;

  in mkIf cfg.enable {
    services.flannel = {

      enable = mkDefault true;
      network = mkDefault top.clusterCidr;
      inherit storageBackend kubeconfig;
      nodeName = top.kubelet.hostname;
    };

    services.kubernetes.kubelet = {
      networkPlugin = mkDefault "cni";
      cni.config = mkDefault [{
        name = "mynet";
        type = "flannel";
        delegate = {
          isDefaultGateway = true;
          bridge = "docker0";
        };
      }];
    };

    systemd.services.mk-docker-opts = {
      description = "Pre-Docker Actions";
      wantedBy = [ "flannel.target" ];
      before = [ "flannel.target" ];
      path = with pkgs; [ gawk gnugrep ];
      script = ''
        ${mkDockerOpts}/mk-docker-opts -d /run/flannel/docker
        systemctl restart docker
      '';
      unitConfig.ConditionPathExists = [ "/run/flannel/subnet.env" ];
      serviceConfig.Type = "oneshot";
    };

    systemd.paths.flannel-subnet-env = {
      wantedBy = [ "mk-docker-opts.service" ];
      pathConfig = {
        PathExists = [ "/run/flannel/subnet.env" ];
        PathChanged = [ "/run/flannel/subnet.env" ];
        Unit = "mk-docker-opts.service";
      };
    };

    systemd.targets.flannel = {
      wantedBy = [ "kube-node-online.target" ];
      before = [ "kube-node-online.target" ];
    };

    systemd.services.flannel = {
      wantedBy = [ "flannel.target" ];
      after = [ "kubelet.target" ];
      before = [ "flannel.target" ];
      path = with pkgs; [ iptables kubectl ];
      environment.KUBECONFIG = kubeconfig;
      preStart = let
        args = [
          "--selector=kubernetes.io/hostname=${top.kubelet.hostname}"
          # flannel exits if node is not registered yet, before that there is no podCIDR
          "--output=jsonpath={.items[0].spec.podCIDR}"
          # if jsonpath cannot be resolved exit with status 1
          "--allow-missing-template-keys=false"
        ];
      in ''
        until kubectl get nodes ${concatStringsSep " " args} 2>/dev/null; do
          echo Waiting for ${top.kubelet.hostname} to be RegisteredNode
          sleep 1
        done
      '';
      unitConfig.ConditionPathExists = flannelPaths;
    };

    systemd.paths.flannel = {
      wantedBy = [ "flannel.service" ];
      pathConfig = {
        PathExists = flannelPaths;
        PathChanged = flannelPaths;
      };
    };

    services.kubernetes.flannel.kubeconfig.server = mkDefault top.apiserverAddress;

    systemd.services.docker = {
      environment.DOCKER_OPTS = "-b none";
      serviceConfig.EnvironmentFile = "-/run/flannel/docker";
    };

    # read environment variables generated by mk-docker-opts
    virtualisation.docker.extraOptions = "$DOCKER_OPTS";

    networking = {
      firewall.allowedUDPPorts = [
        8285  # flannel udp
        8472  # flannel vxlan
      ];
      dhcpcd.denyInterfaces = [ "docker*" "flannel*" ];
    };

    services.kubernetes.pki.certs = {
      flannelClient = top.lib.mkCert {
        name = "flannel-client";
        CN = "flannel-client";
        action = "systemctl restart flannel.service";
      };
    };

    # give flannel som kubernetes rbac permissions if applicable
    services.kubernetes.addonManager.bootstrapAddons = mkIf ((storageBackend == "kubernetes") && (elem "RBAC" top.apiserver.authorizationMode)) {
      flannel-cr = {
        apiVersion = "rbac.authorization.k8s.io/v1beta1";
        kind = "ClusterRole";
        metadata = { name = "flannel"; };
        rules = [{
          apiGroups = [ "" ];
          resources = [ "pods" ];
          verbs = [ "get" ];
        }
        {
          apiGroups = [ "" ];
          resources = [ "nodes" ];
          verbs = [ "list" "watch" ];
        }
        {
          apiGroups = [ "" ];
          resources = [ "nodes/status" ];
          verbs = [ "patch" ];
        }];
      };

      flannel-crb = {
        apiVersion = "rbac.authorization.k8s.io/v1beta1";
        kind = "ClusterRoleBinding";
        metadata = { name = "flannel"; };
        roleRef = {
          apiGroup = "rbac.authorization.k8s.io";
          kind = "ClusterRole";
          name = "flannel";
        };
        subjects = [{
          kind = "User";
          name = "flannel-client";
        }];
      };
    };
  };
}
