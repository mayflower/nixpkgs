{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.gitlabMonitor;
  ruby = pkgs.gitlab-monitor.ruby;
  bundler = pkgs.bundler;
  gemHome = "${pkgs.gitlab-monitor.env}/${ruby.gemPath}";

  gitlabMonitorEnv = {
    GEM_HOME = gemHome;
    BUNDLE_GEMFILE = "${pkgs.gitlab-monitor}/share/gitlab-monitor/Gemfile";
  };
in {
  options = {
    services.gitlabMonitor = {
      enable = mkEnableOption "gitlab-monitor";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.gitlab-monitor = {
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      environment = gitlabMonitorEnv;
      serviceConfig = {
        User = "nobody";
        Group = "nogroup";
        ExecStart = "${pkgs.gitlab-monitor.env}/bin/bundle exec gitlab-mon web -c ${pkgs.gitlab-monitor}/share/gitlab-monitor/config.gitlab-monitor.yml.example";
      };
    };
  };
}
