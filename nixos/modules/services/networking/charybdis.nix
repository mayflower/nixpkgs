{ config, lib, pkgs, ... }:

let
  inherit (lib) mkEnableOption mkIf mkOption singleton types;
  inherit (pkgs) coreutils;
  cfg = config.services.charybdis;

  pkg = cfg.package;

  configFile = pkgs.writeText "charybdis.conf" ''
    ${cfg.config}
  '';
in

{

  ###### interface

  options = {

    services.charybdis = {

      enable = mkEnableOption "Charybdis IRC daemon";

      package = mkOption {
        default = pkgs.charybdis;
        type = types.package;
        description = ''
          Charybdis package to use.
        '';
      };

      config = mkOption {
        type = types.str;
        description = ''
          Charybdis IRC daemon configuration file.
        '';
      };

      statedir = mkOption {
        type = types.path;
        default = "/var/lib/charybdis";
        description = ''
          Location of the state directory of charybdis.
        '';
      };

      user = mkOption {
        type = types.str;
        default = "ircd";
        description = ''
          Charybdis IRC daemon user.
        '';
      };

      group = mkOption {
        type = types.str;
        default = "ircd";
        description = ''
          Charybdis IRC daemon group.
        '';
      };

      motd = mkOption {
        type = types.nullOr types.lines;
        default = null;
        description = ''
          Charybdis MOTD text.

          Charybdis will read its MOTD from /etc/charybdis/ircd.motd .
          If set, the value of this option will be written to this path.
        '';
      };

    };

  };


  ###### implementation

  config = mkIf cfg.enable (lib.mkMerge [
    {
      users.users = singleton {
        name = cfg.user;
        description = "Charybdis IRC daemon user";
        uid = config.ids.uids.ircd;
        group = cfg.group;
      };

      users.groups = singleton {
        name = cfg.group;
        gid = config.ids.gids.ircd;
      };

      systemd.tmpfiles.rules = [
        "d ${cfg.statedir} - ${cfg.user} ${cfg.group} - -"
      ];

      systemd.services.charybdis = {
        description = "Charybdis IRC daemon";
        wantedBy = [ "multi-user.target" ];
        environment = {
          BANDB_DBPATH = "${cfg.statedir}/ban.db";
        };
        serviceConfig = {
          ExecStart = "${pkg}/bin/charybdis-ircd -foreground -logfile /dev/stdout -configfile ${configFile}";
          Group = cfg.group;
          User = cfg.user;
        };
      };

    }

    (mkIf (cfg.motd != null) {
      environment.etc."charybdis/ircd.motd".text = cfg.motd;
    })
  ]);
}
