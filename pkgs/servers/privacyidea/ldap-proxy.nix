{ stdenv, pythonPackages, fetchFromGitHub }:

let

  self = pythonPackages.buildPythonApplication rec {
    name = "privacyidea-ldap-proxy-${version}";
    version = "0.5";

    src = fetchFromGitHub {
      owner = "NetKnights-GmbH";
      repo = "privacyidea-ldap-proxy";
      rev = "v${version}";
      sha256 = "0zmdrym7hb2x7bhv1xsrai0lyznc51kv4gxlzs0na9lv41a632bi";
    };

    checkPhase = ''
      trial pi_ldapproxy.test
    '';

    propagatedBuildInputs = with pythonPackages; [ twisted ldaptor configobj ]
      ++ twisted.extras.tls;

    passthru.env = pythonPackages.python.buildEnv.override {
      extraLibs = propagatedBuildInputs ++ [self];
    };

    passthru.python = pythonPackages.python;

    meta = with stdenv.lib; {
      description = "PrivacyIDEA LDAP Proxy";
      license = licenses.agpl3Plus;
      platforms = platforms.unix;
      maintainers = with maintainers; [ fpletz globin ];
      priority = 10;
    };
  };

in self
