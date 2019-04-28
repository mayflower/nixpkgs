{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.sks;
  sksPkg = cfg.package;
  dbConfig = pkgs.writeText "DB_CONFIG" ''
    ${cfg.extraDbConfig}
  '';

  sksConf = pkgs.writeText "sksconf" ''
    hostname: ${cfg.hostname}
    hkp_address: ${concatStringsSep " " cfg.hkpAddress}
    hkp_port: ${toString cfg.hkpPort}

    ${optionalString (cfg.disableMailsync) "disable_mailsync:"}

    ${cfg.extraConfig}
  '';

  membershipConf = pkgs.writeText "membership" ''
    # A list of SKS keyservers to synchronize with

    # Example:
    #keyserver.linux.it 11370
  '';

  mailsyncConf = pkgs.writeText "mailsync" ''
    # A list of PKS keyserver email addresses to synchronize with

    # Example:
    #pgp-public-keys@pgp.mit.edu
  '';

in {
  meta.maintainers = with maintainers; [ primeos calbrecht jcumming ];

  options = {

    services.sks = {

      enable = mkEnableOption ''
        SKS (synchronizing key server for OpenPGP) and start the database
        server. You need to create "''${dataDir}/dump/*.gpg" for the initial
        import'';

      hostname = mkOption {
        type = types.string;
        default = "localhost";
        description = ''
          The publicly available FQDN under which this SKS is provided.
        '';
      };

      package = mkOption {
        type = types.package;
        default = pkgs.sks;
        defaultText = "pkgs.sks";
        description = "Which SKS derivation to use.";
      };

      dataDir = mkOption {
        type = types.path;
        default = "/var/db/sks";
        example = "/var/lib/sks";
        # TODO: The default might change to "/var/lib/sks" as this is more
        # common. There's also https://github.com/NixOS/nixpkgs/issues/26256
        # and "/var/db" is not FHS compliant (seems to come from BSD).
        description = ''
          Data directory (-basedir) for SKS, where the database and all
          configuration files are located (e.g. KDB, PTree, membership and
          sksconf).
        '';
      };

      extraDbConfig = mkOption {
        type = types.str;
        default = "";
        description = ''
          Set contents of the files "KDB/DB_CONFIG" and "PTree/DB_CONFIG" within
          the ''${dataDir} directory. This is used to configure options for the
          database for the sks key server.

          Documentation of available options are available in the file named
          "sampleConfig/DB_CONFIG" in the following repository:
          https://bitbucket.org/skskeyserver/sks-keyserver/src
        '';
      };

      hkpAddress = mkOption {
        type = types.listOf types.str;
        default = [ "::1" "127.0.0.1" ];
        description = ''
          Domain names, IPv4 and/or IPv6 addresses to listen on for HKP
          requests.
        '';
      };

      disableMailsync = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Disable sending of PKS mailsync messages. This should only
          be activated for standalone servers with an empty mailsyncConfig
          so as to avoid a log file overflowing with ``Failure("No partners specified")``
          errors."
        '';
      };

      hkpPort = mkOption {
        default = 11371;
        type = types.ints.u16;
        description = "HKP port to listen on.";
      };

      webroot = mkOption {
        type = types.nullOr types.path;
        default = "${sksPkg.webSamples}/OpenPKG";
        defaultText = "\${pkgs.sks.webSamples}/OpenPKG";
        description = ''
          Source directory (will be symlinked, if not null) for the files the
          built-in webserver should serve. SKS (''${pkgs.sks.webSamples})
          provides the following examples: "HTML5", "OpenPKG", and "XHTML+ES".
          The index file can be named index.html, index.htm, index.xhtm, or
          index.xhtml. Files with the extensions .css, .es, .js, .jpg, .jpeg,
          .png, or .gif are supported. Subdirectories and filenames with
          anything other than alphanumeric characters and the '.' character
          will be ignored.
        '';
      };

      membershipConfig = mkOption {
        type = types.lines;
        default = membershipConf;
        description = ''
          The SKS will attempt to synchronize its keystore with these
          SKS keyservers.
        '';
      };

      mailsyncConfig = mkOption {
        type = types.lines;
        default = mailsyncConf;
        description = ''
          The SKS will attempt to synchronize its keystore with these
          PKS keyservers.
        '';
      };

      extraConfig = mkOption {
        type = types.lines;
        default = "";
        description = ''
          Configuration lines appended to the main SKS config.
        '';
      };
    };
  };

  config = mkIf cfg.enable {

    environment.systemPackages = [ sksPkg ];

    users = {
      users.sks = {
        createHome = true;
        home = cfg.dataDir;
        isSystemUser = true;
        uid = config.ids.uids.sks;
        group = "sks";
        shell = "${pkgs.coreutils}/bin/true";
        description = "SKS user";
        packages = [ sksPkg pkgs.db ];
      };

      groups."sks".gid = config.ids.gids.sks;
    };

    systemd.services = {
      "sks-db" = {
        description = "SKS database server";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];
        preStart = ''
          ${lib.optionalString (cfg.webroot != null)
            "ln -sfT \"${cfg.webroot}\" web"}
          mkdir -p dump
          ${sksPkg}/bin/sks build dump/*.gpg -n 10 -cache 100 || true #*/
          ${sksPkg}/bin/sks cleandb || true
          ${sksPkg}/bin/sks pbuild -cache 20 -ptree_cache 70 || true

          # link the configuration files
          ln -sfn ${sksConf} sksconf
          ln -sfn ${membershipConf} membership
          ln -sfn ${mailsyncConf} mailsync

          # Check that both database configs are symlinks before overwriting them
          # TODO: The initial build will be without DB_CONFIG, but this will
          # hopefully not cause any significant problems. It might be better to
          # create both directories manually but we have to check that this does
          # not affect the initial build of the DB.
          for CONFIG_FILE in KDB/DB_CONFIG PTree/DB_CONFIG; do
            if [ -e $CONFIG_FILE ] && [ ! -L $CONFIG_FILE ]; then
              echo "$CONFIG_FILE exists but is not a symlink." >&2
              echo "Please remove $PWD/$CONFIG_FILE manually to continue." >&2
              exit 1
            fi
            ln -sf ${dbConfig} $CONFIG_FILE
          done
        '';
        serviceConfig = {
          WorkingDirectory = "~";
          User = "sks";
          Group = "sks";
          Restart = "always";
          ExecStart = "${sksPkg}/bin/sks db";
        };
      };
    };
  };
}
