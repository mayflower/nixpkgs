{ config, lib, pkgs, ... }:

with lib;

let
  top = config.services.kubernetes;
  cfg = top.pki;

  cfsslAPITokenBaseName = "apitoken.secret";
  cfsslAPITokenPath = "${config.services.cfssl.dataDir}/${cfsslAPITokenBaseName}";
  certmgrAPITokenPath = "${top.secretsPath}/${cfsslAPITokenBaseName}";
  cfsslAPITokenLength = 32;

  clusterAdminKubeconfig = with cfg.certs.clusterAdmin;
    top.lib.mkKubeConfig "cluster-admin" {
        server = top.apiserverAddress;
        certFile = cert;
        keyFile = key;
        caFile = "${cfg.kubernetesCaCertPathPrefix}.pem";
    };

  cfsslPort = toString config.services.cfssl.port;
  remote = "https://${top.masterAddress}:${cfsslPort}";
in
{
  ###### interface
  options.services.kubernetes.pki = with lib.types; {

    enable = mkEnableOption "Whether to enable easyCert issuer service.";

    certs = mkOption {
      description = "List of certificate specs to feed to cert generator.";
      default = {};
      type = attrs;
    };

    genCfsslCACert = mkOption {
      description = ''
        Whether to automatically generate cfssl CA certificate and key,
        if they don't exist.
      '';
      default = true;
      type = bool;
    };

    genCfsslAPICerts = mkOption {
      description = ''
        Whether to automatically generate cfssl API webserver TLS cert and key,
        if they don't exist.
      '';
      default = true;
      type = bool;
    };

    genCfsslAPIToken = mkOption {
      description = ''
        Whether to automatically generate cfssl API-token secret,
        if they doesn't exist.
      '';
      default = true;
      type = bool;
    };

    pkiTrustOnBootstrap = mkOption {
      description = "Whether to always trust remote cfssl server upon initial PKI bootstrap.";
      default = true;
      type = bool;
    };

    caCertPathPrefix = mkOption {
      description = ''
        Path-prefrix for the CA-certificate to be used for cfssl signing.
        Suffixes ".pem" and "-key.pem" will be automatically appended for
        the public and private keys respectively.
      '';
      default = "${config.services.cfssl.dataDir}/ca";
      type = str;
    };

    kubernetesCaCertPathPrefix = mkOption {
      description = ''
        Path-prefrix for the kubernetes CA-certificate to be used for multirootca signing.
        Suffixes ".pem" and "-key.pem" will be automatically appended for
        the public and private keys respectively.
      '';
      default = "${top.secretsPath}/kubernetes-ca";
      type = str;
    };

    etcdCaCertPathPrefix = mkOption {
      description = ''
        Path-prefrix for the etcd CA-certificate to be used for multirootca signing.
        Suffixes ".pem" and "-key.pem" will be automatically appended for
        the public and private keys respectively.
      '';
      default = "${top.secretsPath}/etcd-ca";
      type = str;
    };

    frontProxyCaCertPathPrefix = mkOption {
      description = ''
        Path-prefrix for the front proxy CA-certificate to be used for multirootca signing.
        Suffixes ".pem" and "-key.pem" will be automatically appended for
        the public and private keys respectively.
      '';
      default = "${top.secretsPath}/front-proxy-ca";
      type = str;
    };

    caSpec = mkOption {
      description = "Certificate specification for the auto-generated CAcert.";
      default = {
        CN = "kubernetes-cluster-ca";
        O = "NixOS";
        OU = "services.kubernetes.pki.caSpec";
        L = "auto-generated";
      };
      type = attrs;
    };

    etcClusterAdminKubeconfig = mkOption {
      description = ''
        Symlink a kubeconfig with cluster-admin privileges to environment path
        (/etc/&lt;path&gt;).
      '';
      default = null;
      type = nullOr str;
    };

  };

  ###### implementation
  config = mkIf cfg.enable
  (let
    cfsslCertPathPrefix = "${config.services.cfssl.dataDir}/cfssl";
    cfsslCert = "${cfsslCertPathPrefix}.pem";
    cfsslKey = "${cfsslCertPathPrefix}-key.pem";

    ifnotfile = file: cmd: ''
      if [[ ! -f ${file} ]] ; then
        ${cmd}
      fi
    '';

    safecfssl = path: args: csr: ifnotfile "${path}.pem" ''
      ${pkgs.cfssl}/bin/cfssl ${args} ${csr} | ${pkgs.cfssl}/bin/cfssljson -bare ${path}
    '';

    gencsr = name: csr: pkgs.writeText "${name}-csr.json" (builtins.toJSON ({
        key = { algo = "rsa"; size = 2048; };
    } // csr));

    genkey = cn: path: ca: let
      csr = gencsr (baseNameOf path) {
        names = singleton (lib.recursiveUpdate cfg.caSpec { CN = cn; });
      };
      args = "genkey -initca ${lib.optionalString (ca != null)
                "-ca=${ca}.pem -ca-key=${ca}-key.pem"}";
    in
      safecfssl path args csr;

    gencert = cn: path: ca: let
      csr = gencsr (baseNameOf path) { CN = cn; };
      args = "gencert -ca=${ca}.pem -ca-key=${ca}-key.pem";
    in
      safecfssl path args csr;

    commonUsages = ["digital signature" "key encipherment"];
    commonAttrs = { expiry = "720h"; };

    profiles = {
      ca = commonAttrs // {
        usages = [ "signing" "key encipherment" "cert sign" "crl sign" ];
        ca_constraint = { is_ca = true; };
      };
      client = commonAttrs // { usages = commonUsages ++ [ "client auth" ]; };
      peer = commonAttrs // { usages = commonUsages ++ [ "server auth" "client auth" ]; };
      server = commonAttrs // { usages = commonUsages ++ [ "server auth" ]; };
    };

    labels = [{
      label = "root_ca";
      prefix = cfg.caCertPathPrefix;
      profiles = { inherit (profiles) ca; };
    } {
      label = "kubernetes_ca";
      prefix = cfg.kubernetesCaCertPathPrefix;
      profiles = { inherit (profiles) server client; };
    } {
      label = "etcd_ca";
      prefix = cfg.etcdCaCertPathPrefix;
      profiles = { inherit (profiles) peer client; };
    } {
      label = "kubernetes_front_proxy_ca";
      prefix = cfg.frontProxyCaCertPathPrefix;
      profiles = { inherit (profiles) client; };
    }];

    labelPrefix = label: (lib.head (lib.filter (a: a.label == label) labels)).prefix;
  in
  {
    systemd.services.multirootca = mkIf (top.apiserver.enable) (let

      writeConfig = name: profiles:
        pkgs.writeText "multirootca-${name}-config.json" (builtins.toJSON {
          signing.profiles = mapAttrs (_: v: v // { auth_key = "default"; }) profiles;
          auth_keys.default = {
            type = "standard";
            key = "file:${cfsslAPITokenPath}";
          };
        });

      rootsWhitelist = pkgs.writeText "multirootca-roots-whitelist.conf"
        (lib.concatMapStrings (data: ''
          [ ${data.label} ]
          private = file://${data.prefix}-key.pem
          certificate = ${data.prefix}.pem
          config = ${writeConfig data.label data.profiles}
        '') labels);

      rootCa = cfg.caCertPathPrefix;
      kubernetesCa = cfg.kubernetesCaCertPathPrefix;
      etcdCa = cfg.etcdCaCertPathPrefix;
      frontProxyCa = cfg.frontProxyCaCertPathPrefix;
    in {
      description = "Multiroot authenticated signer service";
      wantedBy = [ "kube-certificate-signing-online.service" ];
      before = [ "kube-certificate-signing-online.service" ];
      preStart = ''
        set -e
        mkdir -p ${top.secretsPath}
        mkdir -p $(dirname ${cfsslAPITokenPath})
        ${lib.optionalString cfg.genCfsslCACert
          (genkey "kubernetes-root-ca" rootCa null)}
        ${lib.optionalString cfg.genCfsslAPICerts
          (gencert top.masterAddress cfsslCertPathPrefix rootCa)}
        ${lib.optionalString cfg.genCfsslAPIToken ''
          ${ifnotfile cfsslAPITokenPath ''
            head -c ${toString (cfsslAPITokenLength / 2)} /dev/urandom | od -An -t x | tr -d ' ' >"${cfsslAPITokenPath}"
          ''}
          chown cfssl "${cfsslAPITokenPath}" && chmod 400 "${cfsslAPITokenPath}"
        ''}
        ${genkey "kubernetes-ca" kubernetesCa rootCa}
        ${genkey "etcd-ca" etcdCa rootCa}
        ${genkey "kubernetes-front-proxy-ca" frontProxyCa rootCa}
      '';
      serviceConfig = {
        ExecStart = [
          "${pkgs.cfssl}/bin/multirootca -a ${top.masterAddress}:${cfsslPort} -l peer -roots ${rootsWhitelist} -tls-cert ${cfsslCert} -tls-key ${cfsslKey}"];
        RestartSec = "10s";
        Restart = "on-failure";
      };
    });

    systemd.services.kube-certificate-signing-online = {
      description = "Wait for multirootca to be reachable.";
      wantedBy = [ "kube-certmgr-bootstrap.service" ];
      before = [ "kube-certmgr-bootstrap.service" ];
      path = with pkgs; [ libressl.nc ];
      preStart = ''
        while ! nc -z ${top.masterAddress} ${cfsslPort} ; do
          echo Waiting for ${top.masterAddress}:${cfsslPort} to be reachable.
          sleep 2
        done
      '';
      script = "echo ${top.masterAddress}:${cfsslPort} is reachable";
      serviceConfig = {
        Timeout = "5m";
      };
    };

    systemd.services.kube-certmgr-bootstrap = {
      description = "Kubernetes certmgr bootstrapper";
      wantedBy = [ "certmgr.service" ];
      before = [ "certmgr.service" ];
      after = [ "kube-certificate-signing-online.service" ];
      preStart = ''
        mkdir -p ${top.secretsPath}
        mkdir -p $(dirname ${top.caFile})
      '';
      script = ''
        set -e

        # If there's a cfssl (cert issuer) running locally, then don't rely on user to
        # manually paste it in place. Just symlink.
        # otherwise, create the target file, ready for users to insert the token

        if [ -f "${cfsslAPITokenPath}" ]; then
          ln -fs "${cfsslAPITokenPath}" "${certmgrAPITokenPath}"
        else
          touch "${certmgrAPITokenPath}" && chmod 600 "${certmgrAPITokenPath}"
        fi

        ${optionalString (cfg.pkiTrustOnBootstrap) (lib.concatMapStrings (data: ''
        if [ ! -f "${data.prefix}.pem" ] || [ $(cat "${data.prefix}.pem" | wc -c) -lt 1 ]; then
          ${pkgs.curl}/bin/curl --fail-early -f -kd '{"label":"${data.label}"}' \
          ${remote}/api/v1/cfssl/info | \
          ${pkgs.cfssl}/bin/cfssljson -stdout >${data.prefix}.pem
        fi
        '') labels)}
      '';
      serviceConfig = {
        RestartSec = "10s";
        Restart = "on-failure";
      };
    };

    services.certmgr = {
      enable = true;
      package = pkgs.certmgr-selfsigned;
      svcManager = "command";
      specs =
        let
          mkSpec = _: cert: {
            inherit (cert) action;
            authority = {
              inherit remote;
              file.path = "${labelPrefix cert.label}.pem";
              root_ca = top.caFile;
              profile = cert.profile;
              label = cert.label;
              auth_key_file = "${certmgrAPITokenPath}";
            };
            certificate = {
              path = cert.cert;
            };
            private_key = cert.privateKeyOptions;
            request = {
              inherit (cert) CN hosts;
              key = {
                algo = "rsa";
                size = 2048;
              };
              names = [ cert.fields ];
            };
          };
        in
          mapAttrs mkSpec cfg.certs;
      };

      systemd.services.certmgr.before = [
        "etcd.service"
        "flannel.service"
        "kube-addon-manager.service"
        "kube-apiserver.service"
        "kube-controller-manager.service"
        "kube-scheduler.service"
        "kube-proxy.service"
        "kubelet.service"
      ];

      systemd.services.certmgr.postStart = lib.concatMapStrings
        (cert: ''
          while [[ ! -f ${cert.cert} ]] ; do
            echo Waiting for ${cert.cert} to be present.
            sleep 2
          done
        '') (lib.attrValues cfg.certs);

      #TODO: Get rid of kube-addon-manager in the future for the following reasons
      # - it is basically just a shell script wrapped around kubectl
      # - it assumes that it is clusterAdmin or can gain clusterAdmin rights through serviceAccount
      # - it is designed to be used with k8s system components only
      # - it would be better with a more Nix-oriented way of managing addons
      systemd.services.kube-addon-manager = mkIf top.addonManager.enable (mkMerge [{
        environment.KUBECONFIG = with cfg.certs.addonManager;
          top.lib.mkKubeConfig "addon-manager" {
            server = top.apiserverAddress;
            certFile = cert;
            keyFile = key;
            caFile = "${cfg.kubernetesCaCertPathPrefix}.pem";
          };
        }

        (optionalAttrs (top.addonManager.bootstrapAddons != {}) {
          serviceConfig.PermissionsStartOnly = true;
          preStart = with pkgs;
          let
            files = mapAttrsToList (n: v: writeText "${n}.json" (builtins.toJSON v))
              top.addonManager.bootstrapAddons;
          in
          ''
            export KUBECONFIG=${clusterAdminKubeconfig}
            ${kubectl}/bin/kubectl apply -f ${concatStringsSep " \\\n -f " files}
          '';
        })]);

      environment.etc.${cfg.etcClusterAdminKubeconfig}.source = mkIf (!isNull cfg.etcClusterAdminKubeconfig)
        clusterAdminKubeconfig;

      environment.systemPackages = mkIf (top.kubelet.enable || top.proxy.enable) [
      (pkgs.writeScriptBin "nixos-kubernetes-node-join" ''
        set -e
        exec 1>&2

        if [ $# -gt 0 ]; then
          echo "Usage: $(basename $0)"
          echo ""
          echo "No args. Apitoken must be provided on stdin."
          echo "To get the apitoken, execute: 'sudo cat ${certmgrAPITokenPath}' on the master node."
          exit 1
        fi

        if [ $(id -u) != 0 ]; then
          echo "Run as root please."
          exit 1
        fi

        read -r token
        if [ ''${#token} != ${toString cfsslAPITokenLength} ]; then
          echo "Token must be of length ${toString cfsslAPITokenLength}."
          exit 1
        fi

        echo $token > ${certmgrAPITokenPath}
        chmod 600 ${certmgrAPITokenPath}

        echo "Restarting certmgr..." >&1
        systemctl restart certmgr

        echo "Waiting for certs to appear..." >&1

        ${optionalString top.kubelet.enable ''
          while [ ! -f ${cfg.certs.kubelet.cert} ]; do sleep 1; done
          echo "Restarting kubelet..." >&1
          systemctl restart kubelet
        ''}

        ${optionalString top.proxy.enable ''
          while [ ! -f ${cfg.certs.kubeProxyClient.cert} ]; do sleep 1; done
          echo "Restarting kube-proxy..." >&1
          systemctl restart kube-proxy
        ''}

        ${optionalString top.flannel.enable ''
          while [ ! -f ${cfg.certs.flannelEtcdClient.cert} ]; do sleep 1; done
          echo "Restarting flannel..." >&1
          systemctl restart flannel
        ''}

        echo "Node joined succesfully"
      '')];

      services.etcd = with cfg.certs.etcd; {
        certFile = mkDefault cert;
        keyFile = mkDefault key;
        trustedCaFile = mkDefault "${cfg.etcdCaCertPathPrefix}.pem";
      } // (with cfg.certs.etcdPeer; {
        peerCertFile = mkDefault cert;
        peerKeyFile = mkDefault key;
        peerTrustedCaFile = mkDefault "${cfg.etcdCaCertPathPrefix}.pem";
      });

      services.flannel.etcd = with cfg.certs.flannelEtcdClient; {
        certFile = mkDefault cert;
        keyFile = mkDefault key;
        caFile = mkDefault "${cfg.etcdCaCertPathPrefix}.pem";
      };

      services.kubernetes = {
        caFile = mkDefault "${cfg.caCertPathPrefix}.pem";
        apiserver = mkIf top.apiserver.enable (with cfg.certs.apiServer; {
          etcd = with cfg.certs.apiserverEtcdClient; {
            certFile = mkDefault cert;
            keyFile = mkDefault key;
            caFile = mkDefault "${cfg.etcdCaCertPathPrefix}.pem";
          };
          clientCaFile = mkDefault "${cfg.kubernetesCaCertPathPrefix}.pem";
          tlsCertFile = mkDefault cert;
          tlsKeyFile = mkDefault key;
          serviceAccountKeyFile = mkDefault cfg.certs.serviceAccount.cert;
          kubeletClientCaFile = mkDefault "${cfg.kubernetesCaCertPathPrefix}.pem";
          kubeletClientCertFile = mkDefault cfg.certs.apiserverKubeletClient.cert;
          kubeletClientKeyFile = mkDefault cfg.certs.apiserverKubeletClient.key;
        });
        controllerManager = mkIf top.controllerManager.enable {
          serviceAccountKeyFile = mkDefault cfg.certs.serviceAccount.key;
          rootCaFile = mkDefault "${cfg.kubernetesCaCertPathPrefix}.pem";
          kubeconfig = with cfg.certs.controllerManagerClient; {
            certFile = mkDefault cert;
            keyFile = mkDefault key;
            caFile = mkDefault "${cfg.kubernetesCaCertPathPrefix}.pem";
          };
        };
        scheduler = mkIf top.scheduler.enable {
          kubeconfig = with cfg.certs.schedulerClient; {
            certFile = mkDefault cert;
            keyFile = mkDefault key;
            caFile = mkDefault "${cfg.kubernetesCaCertPathPrefix}.pem";
          };
        };
        kubelet = mkIf top.kubelet.enable {
          clientCaFile =  mkDefault "${cfg.kubernetesCaCertPathPrefix}.pem";
          tlsCertFile = mkDefault cfg.certs.kubelet.cert;
          tlsKeyFile = mkDefault cfg.certs.kubelet.key;
          kubeconfig = with cfg.certs.kubeletClient; {
            certFile = mkDefault cert;
            keyFile = mkDefault key;
            caFile = mkDefault "${cfg.kubernetesCaCertPathPrefix}.pem";
          };
        };
        proxy = mkIf top.proxy.enable {
          kubeconfig = with cfg.certs.kubeProxyClient; {
            certFile = mkDefault cert;
            keyFile = mkDefault key;
            caFile = mkDefault "${cfg.kubernetesCaCertPathPrefix}.pem";
          };
        };
      };
    });
}
