# NixOS module for lighttpd web server

{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.services.lighttpd;

  # List of known lighttpd modules, ordered by how the lighttpd documentation
  # recommends them being imported:
  # http://redmine.lighttpd.net/projects/1/wiki/Server_modulesDetails
  #
  # Some modules are always imported and should not appear in the config:
  # disallowedModules = [ "mod_indexfile" "mod_dirlisting" "mod_staticfile" ];
  #
  # Get full module list: "ls -1 $lighttpd/lib/*.so"
  allKnownModules = [
    "mod_rewrite"
    "mod_redirect"
    "mod_alias"
    "mod_access"
    "mod_auth"
    "mod_status"
    "mod_simple_vhost"
    "mod_evhost"
    "mod_userdir"
    "mod_secdownload"
    "mod_fastcgi"
    "mod_proxy"
    "mod_cgi"
    "mod_ssi"
    "mod_compress"
    "mod_usertrack"
    "mod_expire"
    "mod_rrdtool"
    "mod_accesslog"
    # Remaining list of modules, order assumed to be unimportant.
    "mod_cml"
    "mod_dirlisting"
    "mod_evasive"
    "mod_extforward"
    "mod_flv_streaming"
    "mod_magnet"
    "mod_mysql_vhost"
    "mod_scgi"
    "mod_setenv"
    "mod_trigger_b4_dl"
    "mod_webdav"
  ];

  maybeModuleString = moduleName:
    if elem moduleName cfg.enableModules then ''"${moduleName}"'' else "";

  modulesIncludeString = concatStringsSep ",\n"
    (filter (x: x != "") (map maybeModuleString allKnownModules));

  configFile = if cfg.configText != "" then
    pkgs.writeText "lighttpd.conf" ''
      ${cfg.configText}
    ''
    else
    pkgs.writeText "lighttpd.conf" ''
      server.document-root = "${cfg.document-root}"
      server.port = ${toString cfg.port}
      server.username = "lighttpd"
      server.groupname = "lighttpd"

      # As for why all modules are loaded here, instead of having small
      # server.modules += () entries in each sub-service extraConfig snippet,
      # read this:
      #
      #   http://redmine.lighttpd.net/projects/1/wiki/Server_modulesDetails
      #   http://redmine.lighttpd.net/issues/2337
      #
      # Basically, lighttpd doesn't want to load (or even silently ignore) a
      # module for a second time, and there is no way to check if a module has
      # been loaded already. So if two services were to put the same module in
      # server.modules += (), that would break the lighttpd configuration.
      server.modules = (
          ${modulesIncludeString}
      )

      # Logging (logs end up in systemd journal)
      accesslog.use-syslog = "enable"
      server.errorlog-use-syslog = "enable"

      mimetype.assign = (
          ".html" => "text/html",
          ".htm" => "text/html",
          ".txt" => "text/plain",
          ".jpg" => "image/jpeg",
          ".png" => "image/png",
          ".css" => "text/css"
          )

      static-file.exclude-extensions = ( ".fcgi", ".php", ".rb", "~", ".inc" )
      index-file.names = ( "index.html" )

      ${if cfg.mod_userdir then ''
        userdir.path = "public_html"
      '' else ""}

      ${if cfg.mod_status then ''
        status.status-url = "/server-status"
        status.statistics-url = "/server-statistics"
        status.config-url = "/server-config"
      '' else ""}

      ${cfg.extraConfig}
    '';

in

{

  options = {

    services.lighttpd = {

      enable = mkOption {
        default = false;
        type = types.bool;
        description = ''
          Enable the lighttpd web server.
        '';
      };

      port = mkOption {
        default = 80;
        type = types.int;
        description = ''
          TCP port number for lighttpd to bind to.
        '';
      };

      document-root = mkOption {
        default = "/srv/www";
        type = types.path;
        description = ''
          Document-root of the web server. Must be readable by the "lighttpd" user.
        '';
      };

      mod_userdir = mkOption {
        default = false;
        type = types.bool;
        description = ''
          If true, requests in the form /~user/page.html are rewritten to take
          the file public_html/page.html from the home directory of the user.
        '';
      };

      enableModules = mkOption {
        type = types.listOf types.str;
        default = [ ];
        example = [ "mod_cgi" "mod_status" ];
        description = ''
          List of lighttpd modules to enable. Sub-services take care of
          enabling modules as needed, so this option is mainly for when you
          want to add custom stuff to
          <option>services.lighttpd.extraConfig</option> that depends on a
          certain module.
        '';
      };

      mod_status = mkOption {
        default = false;
        type = types.bool;
        description = ''
          Show server status overview at /server-status, statistics at
          /server-statistics and list of loaded modules at /server-config.
        '';
      };

      configText = mkOption {
        default = "";
        type = types.lines;
        example = ''...verbatim config file contents...'';
        description = ''
          Overridable config file contents to use for lighttpd. By default, use
          the contents automatically generated by NixOS.
        '';
      };

      extraConfig = mkOption {
        default = "";
        type = types.lines;
        description = ''
          These configuration lines will be appended to the generated lighttpd
          config file. Note that this mechanism does not work when the manual
          <option>configText</option> option is used.
        '';
      };

    };

  };

  config = mkIf cfg.enable {

    assertions = [
      { assertion = all (x: elem x allKnownModules) cfg.enableModules;
        message = ''
          One (or more) modules in services.lighttpd.enableModules are
          unrecognized.

          Known modules: ${toString allKnownModules}

          services.lighttpd.enableModules: ${toString cfg.enableModules}
        '';
      }
    ];

    services.lighttpd.enableModules = mkMerge
      [ (mkIf cfg.mod_status [ "mod_status" ])
        (mkIf cfg.mod_userdir [ "mod_userdir" ])
        # always load mod_accesslog so that we can log to the journal
        [ "mod_accesslog" ]
      ];

    systemd.services.lighttpd = {
      description = "Lighttpd Web Server";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig.ExecStart = "${pkgs.lighttpd}/sbin/lighttpd -D -f ${configFile}";
      # SIGINT => graceful shutdown
      serviceConfig.KillSignal = "SIGINT";
    };

    users.extraUsers.lighttpd = {
      group = "lighttpd";
      description = "lighttpd web server privilege separation user";
      uid = config.ids.uids.lighttpd;
    };

    users.extraGroups.lighttpd.gid = config.ids.gids.lighttpd;
  };
}
