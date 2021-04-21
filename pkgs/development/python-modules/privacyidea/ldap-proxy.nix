{ lib, buildPythonPackage, fetchFromGitHub, twisted, ldaptor, configobj }:

buildPythonPackage rec {
  pname = "privacyidea-ldap-proxy";
  version = "0.7.0-dev-py3k";

  src = fetchFromGitHub {
    owner = "privacyidea";
    repo = pname;
    rev = "fea1907a88352ffd0c0030172d7a5e598c57c251";
    sha256 = "17mbicdz4cs1qsp3ap1vvglak0xfzncvaff2z07zmszjx7nn7a6z";
  };

  propagatedBuildInputs = [ twisted ldaptor configobj ];

  doCheck = true;

  pythonImportsCheck = [ "pi_ldapproxy" ];

  meta = with lib; {
    description = "LDAP Proxy to intercept LDAP binds and authenticate against privacyIDEA";
    homepage = "https://github.com/privacyidea/privacyidea-ldap-proxy";
    license = licenses.agpl3;
    maintainers = [ maintainers.globin ];
  };
}
