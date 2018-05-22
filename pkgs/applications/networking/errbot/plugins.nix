{ stdenv, fetchFromGitHub }:
rec {
  mkErrbotPlugin = { withPackages ? _: [], pname, version, ... }@args:
    stdenv.mkDerivation ({
      pname = "errbot-plugin-${pname}";
      name = "${pname}-${version}";

      passthru = { inherit withPackages; };

      dontBuild = true;
      installPhase = ''
        mkdir -p $out
        for f in $(find -mindepth 1 -a -maxdepth 1 -a \
          \( -type d -o -iname "*.py" -o -iname "*.plug" \)); do
          cp -r $f $out
        done
      '';
    } // (builtins.removeAttrs args ["withPackages"]));
  xmppbridge = mkErrbotPlugin rec {
    pname = "xmppbridge";
    version = "0.1.0";

    src = fetchFromGitHub {
      owner = "mayflower";
      repo = "errbot-xmppbridge";
      rev = version;
      sha256 = "0lilkg9nfavw7blfj4qp5sngm459b8ngzy4zqlh41wmkm89czz0v";
    };

    meta = with stdenv.lib; {
      description = "An errbot plugin to bridge chatrooms to an XMPP server";
      license = licenses.asl20;
      maintainers = [ maintainers.globin ];
      platforms = platforms.all;
    };
  };
  karma = mkErrbotPlugin {
    pname = "karma";
    version = "2016-09-08";
    src = fetchFromGitHub {
      owner = "errbotters";
      repo = "err-karma";
      rev = "f3f60b2534184c7498803deabbb3038de1a69363";
      sha256 = "11b4balrvqs7kw4nrgxqj0c2z6i4fya2xcgcqic9xr71cs7yar3l";
    };
  };
  repohook = mkErrbotPlugin {
    pname = "repohook";
    version = "2017-05-29";
    src = fetchFromGitHub {
      owner = "mayflower";
      repo = "err-githubhook";
      rev = "0ec039eda324d06fb3cc35eb2f52b5df9105feeb";
      sha256 = "1l4bqmnmcvwv983b96snd4pdmxssjxdj3vp6rlp73p9631nrcz2c";
    };
  };
  alerrtmangerr = mkErrbotPlugin {
    pname = "alerrtmanagerr";
    version = "2017-01-18";
    src = fetchFromGitHub {
      owner = "mayflower";
      repo = "errbot-alerrtmanagerr";
      rev = "f840704fd4366cc5e0ad4f92c1dad81bd1838799";
      sha256 = "1drvc03bja4g66cjifmg6pbwb5qikamnwr8za1hdfzywdkaapbw6";
    };
  };
  atlassian = mkErrbotPlugin {
    pname = "atlassian";
    version = "2018-05-16";
    src = fetchFromGitHub {
      owner = "mayflower";
      repo = "err-atlassian";
      rev = "7c1aefd0829c0a144e6ff6a6ad43daf6073b0de3";
      sha256 = "18126pc8hxxqb60fwrmxrcpv1vyddbncp72sp2ik88gq7qf6ghcn";
    };
    withPackages = ps: with ps; [ jira oauth2 tlslite ];
  };
  homeassistant = mkErrbotPlugin {
    pname = "homeassistant";
    version = "2017-09-18";
    src = fetchFromGitHub {
      owner = "btotharye";
      repo = "err-homeassistant";
      rev = "a9d3c60cc7f36e71c982746c09dba4d0642bf95a";
      sha256 = "0a8401yir6g3iicnls87n11sa1dklqz4f7cs2nw0zsdgpvvygada";
    };
    withPackages = ps: with ps; [ requests fuzzywuzzy python-Levenshtein ];
  };
}
