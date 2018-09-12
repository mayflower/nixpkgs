{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.services.rspamd;

  mkBindSockets = socks: concatStringsSep "\n" (map (each: "  bind_socket = \"${each}\"") socks);

   rspamdConfFile = pkgs.writeText "rspamd.conf"
    ''
      .include "$CONFDIR/common.conf"

      .include(try=true,priority=1,duplicate=merge) "${pkgs.writeText "rspamd.conf.local" cfg.localConfig}"
      .include(try=true,priority=10) "${pkgs.writeText "rspamd.conf.local" cfg.overrideConfig}"

      options {
        pidfile = "$RUNDIR/rspamd.pid";
        .include "$CONFDIR/options.inc"
      }

      logging {
        type = "syslog";
        .include "$CONFDIR/logging.inc"
      }

      worker {
      ${mkBindSockets cfg.bindSocket}
        .include "$CONFDIR/worker-normal.inc"
      }

      worker {
      ${mkBindSockets cfg.bindUISocket}
        .include "$CONFDIR/worker-controller.inc"
      }

      worker "rspamd_proxy" {
      ${mkBindSockets cfg.bindMilter}
        .include "$CONFDIR/worker-proxy.inc"
        .include(try=true; priority=10) "${pkgs.writeText "rspamd-worker-proxy.inc" ''
          upstream "local" {
            default = true;
            self_scan = yes;
          }
        ''}"
      }
   '';

in

{

  ###### interface

  options = {

    services.rspamd = {

      enable = mkEnableOption "Whether to run the rspamd daemon.";

      debug = mkOption {
        default = false;
        description = "Whether to run the rspamd daemon in debug mode.";
      };

      bindSocket = mkOption {
        type = types.listOf types.str;
        default = [ "/run/rspamd/rspamd.sock mode=0660 owner=rspamd group=rspamd" ];
        example = [
          "/run/rspamd.sock mode=0666 owner=rspamd"
          "*:11333"
        ];
        description = ''
          List of sockets to listen, in format acceptable by rspamd
        '';
      };

      bindMilter = mkOption {
        type = types.listOf types.str;
        default = [ "/run/rspamd/milter.sock mode=0660 owner=rspamd group=rspamd" ];
        example = [
          "/run/rspamd.sock mode=0666 owner=rspamd"
          "*:11332"
        ];
        description = ''
          List of proxy milter sockets to listen, in format acceptable by rspamd
        '';
      };

      enablePostfix = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Integrate rspamd proxy milter via <literal>/run/rspamd/milter.sock</literal>
          into the local Postfix config.
        '';
      };

      bindUISocket = mkOption {
        type = types.listOf types.str;
        default = [
          "localhost:11334"
        ];
        description = ''
          List of sockets for web interface, in format acceptable by rspamd
        '';
      };

      user = mkOption {
        type = types.string;
        default = "rspamd";
        description = ''
          User to use when no root privileges are required.
        '';
      };

      group = mkOption {
        type = types.string;
        default = "rspamd";
        description = ''
          Group to use when no root privileges are required.
        '';
      };

      localConfig = mkOption {
        type = types.lines;
        default = "";
        description = ''
          Rspamd config that merges with the defaults.
        '';
      };

      overrideConfig = mkOption {
        type = types.lines;
        default = "";
        description = ''
          Rspamd config that overrides the defaults.
        '';
      };
    };
  };


  ###### implementation

  config = mkMerge [
    (mkIf cfg.enable {
      # Allow users to run 'rspamc' and 'rspamadm'.
      environment.systemPackages = [ pkgs.rspamd ];

      services.rspamd = {
        bindSocket = mkDefault [ "/run/rspamd/rspamd.sock mode=0660 owner=${cfg.user} group=${cfg.group}" ];
        bindMilter = mkDefault [ "/run/rspamd/milter.sock mode=0660 owner=${cfg.user} group=${cfg.group}" ];
      };

      users.users = singleton {
        name = cfg.user;
        description = "rspamd daemon";
        uid = config.ids.uids.rspamd;
        group = cfg.group;
      };

      users.groups = singleton {
        name = cfg.group;
        gid = config.ids.gids.rspamd;
      };

      systemd.services.rspamd = {
        description = "Rspamd Service";

        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" ];

        serviceConfig = {
          ExecStart = "${pkgs.rspamd}/bin/rspamd ${optionalString cfg.debug "-d"} --user=${cfg.user} --group=${cfg.group} --pid=/run/rspamd.pid -c ${rspamdConfFile} -f";
          Restart = "always";
          RuntimeDirectory = "rspamd";
          PrivateTmp = true;
        };

        preStart = ''
          ${pkgs.coreutils}/bin/mkdir -p /var/lib/rspamd
          ${pkgs.coreutils}/bin/chown ${cfg.user}:${cfg.group} /var/lib/rspamd
        '';
      };
    })

    (mkIf (cfg.enable && cfg.enablePostfix) {
      services.postfix.config = {
        smtpd_milters = [ "unix:/run/rspamd/milter.sock" ];
        milter_protocol = "6";
        milter_mail_macros = "i {mail_addr} {client_addr} {client_name} {auth_authen}";
        milter_default_action = mkDefault "tempfail";
      };
      users.extraUsers.${config.services.postfix.user}.extraGroups = [ cfg.group ];
    })
  ];
}
