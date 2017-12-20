{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.security.acme;

  certOpts = { name, ... }: {
    options = {
      http.enable = mkEnableOption "http-01 ACME verfication";
      http.webroot = mkOption {
        type = types.str;
        example = "/var/lib/acme/acme-challenges";
        default = "/run/acme";
        description = ''
          Where the webroot of the HTTP vhost is located.
          <filename>.well-known/acme-challenge/</filename> directory
          will be created below the webroot if it doesn't exist.
          <literal>http://example.org/.well-known/acme-challenge/</literal> must also
          be available (notice unencrypted HTTP).
        '';
      };

      dns.enable = mkEnableOption "dns-01 ACME verification";
      dns.hook = mkOption {
        type = types.str;
        description = ''
          Name of the hook from acme.sh or from
          <literal>security.acme.hooks.dns</literal>.
        '';
      };
      dns.sleep = mkOption {
        type = types.str;
        default = 23;
        description = ''
          How long to wait for propagation of DNS records.
        '';
      };

      domain = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Domain to fetch certificate for (defaults to the entry name)";
      };

      owner = mkOption {
        type = types.str;
        default = "root";
        description = "Owner of the private key.";
      };

      group = mkOption {
        type = types.str;
        default = "root";
        description = "Group of the private key.";
      };

      allowKeysForGroup = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Give read permissions to the specified group
          (<option>security.acme.cert.&lt;name&gt;.group</option>) to
          read SSL private keys.
        '';
      };

      deployHooks = mkOption {
        type = types.listOf types.str;
        default = [];
        example = [ "strongswan" "my-deploy-hook" ];
        description = ''
        '';
      };

      extraEnvironment = mkOption {
        type = types.attrsOf types.str;
        default = {};
        example = {
          DNS_USERNAME = "foo";
          DNS_PASSWORD = "bar";
        };
        description = ''
          Environment variables to pass to acme.sh and the hook scripts
          in addition to those defined in
          <literal>security.acme.environment</literal>.
          See acme.sh documentation for more information.
        '';
      };

      directory = mkOption {
        type = types.str;
        readOnly = true;
        default = "/var/lib/acme/${name}";
        description = "Directory where certificate and other state is stored.";
      };

      extraDomains = mkOption {
        type = types.listOf types.str;
        default = [];
        example = [ "example.org" "mydomain.org" ];
        description = ''
          A list of extra domain names, which are included in the one certificate to be issued, with their
          own server roots if needed.
        '';
      };
    };
  };

  scriptHome = pkgs.runCommand "acme-script-home" {} ''
    mkdir -p $out/dnsapi $out/deploy
    ln -s ${pkgs.acme-sh.scripts}/dnsapi/*.sh $out/dnsapi
    ln -s ${pkgs.acme-sh.scripts}/deploy/*.sh $out/deploy

    ${concatStrings (flip mapAttrsToList cfg.hooks.dns (k: v: ''
      ln -s ${v} $out/dnsapi/${k}.sh
    ''))}

    ${concatStrings (flip mapAttrsToList cfg.hooks.deploy (k: v: ''
      ln -s ${v} $out/deploy/${k}.sh
    ''))}
  '';

  certFileTypes = [ "cert" "fullchain" "ca" "key" ];

  certPaths = name:
    genAttrs certFileTypes (c: ''"${cfg.directory}/${name}/${c}.pem"'');

  setCertPermissions = name: data:
    let
      rights = if data.allowKeysForGroup then "640" else "600";
      files = concatStringsSep " " (attrValues (certPaths name));
    in
      ''
        chmod ${rights} ${files}
        chown '${data.owner}:${data.group}' ${files}
      '';

  certPathFlags = name: data:
    concatStringsSep " "
      (mapAttrsToList (k: path: "--${k}-file ${path}") (certPaths name));

in

{

  ###### interface

  options = {
    security.acme = {

      hooks.dns = mkOption {
        type = types.attrsOf types.str;
        default = {};
        example = {
          "mydnsapi" = ''
            curl -x PUT ...
          '';
          "superdns" = ./scripts/superdns-api.sh;
        };
        description = ''
          Additional dns hook shell scripts. See acme.sh documentation.
        '';
      };

      hooks.deploy = mkOption {
        type = types.attrsOf types.str;
        default = {};
        example = {
          "some-host" = ''
            rsync -a ...
          '';
          "other-host" = ./scripts/other-host-deploy-hook.sh;
        };
        description = ''
          Additional deploy hook shell scripts. See acme.sh documentation.
        '';
      };

      email = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Contact email address for the CA to be able to reach you.";
      };

      validMin = mkOption {
        type = types.int;
        default = 30 * 24 * 3600;
        description = "Minimum remaining validity before renewal in seconds.";
      };

      renewInterval = mkOption {
        type = types.str;
        default = "weekly";
        description = ''
          Systemd calendar expression when to check for renewal. See
          <citerefentry><refentrytitle>systemd.time</refentrytitle>
          <manvolnum>7</manvolnum></citerefentry>.
        '';
      };

      preliminarySelfsigned = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Whether a preliminary self-signed certificate should be generated before
          doing ACME requests. This can be useful when certificates are required in
          a webserver, but ACME needs the webserver to make its requests.

          With preliminary self-signed certificate the webserver can be started and
          can later reload the correct ACME certificates.
        '';
      };

      production = mkOption {
        type = types.bool;
        default = false;
        description = ''
          If set to true, use Let's Encrypt's production environment
          instead of the staging environment. The main benefit of the
          staging environment is to get much higher rate limits.

          See
          <literal>https://letsencrypt.org/docs/staging-environment</literal>
          for more detail.
        '';
      };

      environment = mkOption {
        type = types.attrsOf types.str;
        default = {};
        example = {
          DNS_USERNAME = "foo";
          DNS_PASSWORD = "bar";
        };
        description = ''
          Environment variables to pass to acme.sh and the hook scripts.
          See acme.sh documentation for more information.
        '';
      };

      certs = mkOption {
        default = { };
        type = with types; attrsOf (submodule certOpts);
        description = ''
          Attribute set of certificates to get signed and renewed. Creates
          <literal>acme-''${cert}.{service,timer}</literal> systemd units for
          each certificate defined here. Other services can add dependencies
          to those units if they rely on the certificates being present,
          or trigger restarts of the service if certificates get renewed.
        '';
      };
    };
  };

  ###### implementation

  config = mkIf (cfg.certs != { }) {

    systemd.services.acme-issue-selfsigned = {
      before = [ "acme-selfsigned-certificates.target" ];
      wantedBy = [ "acme-selfsigned-certificates.target" ];
      script =
        ''
          workdir="${cfg.directory}/.selfsigned";
          mkdir -p $workdir
          if [ ! -e "$workdir/server.crt" ]; then
            ${pkgs.openssl.bin}/bin/openssl genrsa -des3 -passout pass:x -out $workdir/server.pass.key 2048
            ${pkgs.openssl.bin}/bin/openssl rsa -passin pass:x -in $workdir/server.pass.key -out $workdir/server.key
            ${pkgs.openssl.bin}/bin/openssl req -new -key $workdir/server.key -out $workdir/server.csr \
              -subj "/C=UK/ST=Warwickshire/L=Leamington/O=OrgName/OU=IT Department/CN=example.com"
            ${pkgs.openssl.bin}/bin/openssl x509 -req -days 1 -in $workdir/server.csr -signkey $workdir/server.key -out $workdir/server.crt

            # Clean up working directory
            rm $workdir/server.csr
            rm $workdir/server.pass.key
          fi
        '' + concatStrings (flip mapAttrsToList cfg.certs (name: data:
          let
            cpath = "${cfg.directory}/${name}";
            rights = if data.allowKeysForGroup then "640" else "600";
          in
            ''
              ## ${name}
              if [ ! -e "${cpath}/key.pem" ]; then
                mkdir -p ${cpath}
                # Move key to destination
                cp $workdir/server.key ${cpath}/key.pem
                cp $workdir/server.crt ${cpath}/fullchain.pem
                cp $workdir/server.crt ${cpath}/ca.pem
                cp $workdir/server.crt ${cpath}/cert.pem

                ${setCertPermissions name data}
              fi
            ''));
      unitConfig.ConditionPathExists = flip mapAttrsToList cfg.certs (name: _: "|!${cfg.directory}/${name}/key.pem");
      serviceConfig = {
        Type = "oneshot";
      };
    };

    systemd.targets."acme-selfsigned-certificates" = {};
    systemd.targets."acme-certificates" = {};

    systemd.timers.acme-renew = {
      description = "Timer to renew all ACME certificates";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = cfg.renewInterval;
        Unit = "acme-issue.service";
        Persistent = "yes";
      };
    };

    systemd.services.acme-issue = let
      certToCmd = name: data: let
        domain = if (data.domain == null) then name else data.domain;
        domainFlags = concatMapStringsSep " " (d: "-d ${d}") ([domain] ++ data.extraDomains);
        methodFlags =
          if data.http.enable then
            "--webroot ${data.http.webroot}"
          else if data.dns.enable then
            "--dns ${data.dns.hook} --dnssleep ${data.dns.sleep}"
          else
            throw "No ACME method defined for ${name}";
        deployHooksFlags = concatMapStringsSep " " (h: "--deploy-hook ${h}") data.deployHooks;
        environment = data.extraEnvironment // { CERT_HOME = "${cfg.directory}/${name}/.acme.sh"; };
        exports = concatStrings (flip mapAttrsToList environment (k: v: ''
          export ${k}="${v}"
        ''));
      in
        ''
          (
            set +e
            ${exports}

            echo "Issuing certificate ${name}"

            ${pkgs.acme-sh}/bin/acme.sh --issue \
              ${optionalString (!cfg.production) "--staging"} \
              ${domainFlags} \
              ${methodFlags} \
              ${certPathFlags name data}

            ${optionalString (deployHooksFlags != "") ''
              if [ "$?" == "0" ]; then
                ${pkgs.acme-sh}/bin/acme.sh --deploy \
                  ${domainFlags} \
                  ${deployHooksFlags}
              fi
            ''}

            ${setCertPermissions name data}
          )
        '';
    in {
      after = [ "acme-issue-selfsigned.service" ];
      wants = [ "acme-issue-selfsigned.service" ];
      before = [ "acme-certificates.target" ];
      wantedBy = [ "acme-certificates.target" ];
      environment = cfg.environment // {
        "LE_CONFIG_HOME" = "${cfg.directory}/.acme.sh";
        "ACCOUNT_EMAIL" = optionalString (cfg.email != null) cfg.email;
        "_SCRIPT_HOME" = scriptHome;
        "NO_TIMESTAMP" = "1";
      };
      script = concatStrings (mapAttrsToList certToCmd cfg.certs);
      serviceConfig = {
        Type = "oneshot";
        PrivateTmp = true;
        WorkingDirectory = "/tmp";
      };
    };
  };

  meta = {
    maintainers = with lib.maintainers; [ abbradar fpletz globin ];
    doc = ./acme.xml;
  };
}
