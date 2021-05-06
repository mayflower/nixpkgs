{ config, pkgs, lib, ... }:
let
  cfg = config.services.calendso;

  commonExecConfig = {
    StateDirectory = "calendso";
    CacheDirectory = "calendso";
    User = "calendso";
    Group = "calendso";
    DynamicUser = true;
    EnvironmentFile = [ cfg.environmentFile "${pkgs.calendso}/libexec/calendso/prisma.env" ];
    WorkingDirectory = "${pkgs.calendso}/libexec/calendso/deps/calendso";
  };
in {
  options.services.calendso = {
    enable = lib.mkEnableOption "calendso scheduling tool";
    environmentFile = lib.mkOption {
      type = lib.types.path;
      description = ''
        Path to a file which is added to calendso's environment. This should contain:
          - DATABASE_URL, a URL pointing to a postgresql database that calendso can access
          - GOOGLE_API_CREDENTIALS, see calendso docs at https://github.com/calendso/calendso#obtaining-the-google-api-credentials
          - NEXTAUTH_URL, the URL at which the instance will be reachable to clients
      '';
    };
  };
  config = lib.mkIf cfg.enable {

    systemd.services.calendso-init-db = {
      serviceConfig = commonExecConfig // {
        Type = "oneshot";
        ExecStart = "${pkgs.calendso}/libexec/calendso/node_modules/.bin/prisma db push --preview-feature --schema ${pkgs.calendso}/libexec/calendso/node_modules/calendso/prisma/schema.prisma";
      };
    };

    systemd.services.calendso = {
      requires = ["calendso-init-db.service"];
      after = ["calendso-init-db.service"];
      wantedBy = ["multi-user.target"];
      serviceConfig = commonExecConfig // {
        ExecStart = "${pkgs.calendso}/libexec/calendso/node_modules/.bin/next start";
      };
    };

    systemd.services.calendso-prisma-studio = {
      requires = ["calendso-init-db.service"];
      after = ["calendso-init-db.service"];
      script = ''
        export HOME="$CACHE_DIRECTORY"
        exec ${pkgs.calendso}/libexec/calendso/node_modules/.bin/prisma studio --schema ${pkgs.calendso}/libexec/calendso/node_modules/calendso/prisma/schema.prisma
      '';
      serviceConfig = commonExecConfig;
    };
  };
}
