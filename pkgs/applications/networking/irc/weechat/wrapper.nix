{ stdenv, runCommand, writeScriptBin, buildEnv
, perlPackages, runtimeShell
}:

with stdenv.lib;

weechat:

let
  wrapper = {
    configure ? { availablePlugins, ... }: { plugins = builtins.attrValues availablePlugins; }
  }:

  let
    perlInterpreter = perlPackages.perl;
    scriptsPyPackages = ps: flatten (flip map (config.scripts or []) (s: (s.withPyPackages or (_: [])) ps));
    availablePlugins = let
        simplePlugin = name: { pluginFile = "${weechat.${name}}/lib/weechat/plugins/${name}.so"; };
      in rec {
        python = {
          pluginFile = "${weechat.python}/lib/weechat/plugins/python.so";
          extraEnv = ''
            export PYTHONHOME="${weechat.pythonPkg.withPackages scriptsPyPackages}"
          '';
        };
        perl = (simplePlugin "perl") // {
          extraEnv = ''
            export PATH="${perlInterpreter}/bin:$PATH"
          '';
        };
        tcl = simplePlugin "tcl";
        ruby = simplePlugin "ruby";
        guile = simplePlugin "guile";
        lua = simplePlugin "lua";
      };

    config = configure { inherit availablePlugins; };

    plugins = config.plugins or (builtins.attrValues availablePlugins);

    pluginsDir = runCommand "weechat-plugins" {} ''
      mkdir -p $out/plugins
      for plugin in ${concatMapStringsSep " " (p: p.pluginFile) plugins} ; do
        ln -s $plugin $out/plugins
      done
    '';

    init = let
      init = builtins.replaceStrings [ "\n" ] [ ";" ] (config.init or "");

      mkScript = drv: flip map drv.scripts (script: "/script load ${drv}/share/${script}");

      scripts = builtins.concatStringsSep ";" (foldl (scripts: drv: scripts ++ mkScript drv)
        [ ] (config.scripts or []));
    in "${scripts};${init}";

    mkWeechat = bin: (writeScriptBin bin ''
      #!${runtimeShell}
      export WEECHAT_EXTRA_LIBDIR=${pluginsDir}
      ${concatMapStringsSep "\n" (p: p.extraEnv or "") plugins}
      exec ${weechat}/bin/${bin} "$@" --run-command ${escapeShellArg init}
    '') // {
      inherit (weechat) name;
      unwrapped = weechat;
    };
  in buildEnv {
    name = "weechat-bin-env-${weechat.version}";
    paths = [
      (mkWeechat "weechat")
      (mkWeechat "weechat-headless")
    ];
    meta = builtins.removeAttrs weechat.meta [ "outputsToInstall" ];
  };

in makeOverridable wrapper
