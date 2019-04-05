{ stdenv, pythonPackages, fetchFromGitHub }:

let

  self = pythonPackages.buildPythonApplication rec {
    name = "privacyidea-ldap-proxy-${version}";
    version = "0.6.1";

    src = fetchFromGitHub {
      owner = "NetKnights-GmbH";
      repo = "privacyidea-ldap-proxy";
      rev = "v${version}";
      sha256 = "1kc1n9wr1a66xd5zvl6dq78xnkqkn5574jpzashc99pvm62dr24j";
    };

    checkPhase = ''
      trial pi_ldapproxy.test
    '';

    propagatedBuildInputs = with pythonPackages; [ twisted ldaptor configobj ]
      ++ twisted.extras.tls;
    checkInputs = with pythonPackages; [ twisted ];

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
