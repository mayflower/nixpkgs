{ lib
, buildPythonPackage
, fetchPypi
, twisted
, passlib
, pyopenssl
, pyparsing
, service-identity
, zope_interface
, isPy3k
, python
}:

buildPythonPackage rec {
  pname = "ldaptor";
  version = "21.2.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-jEnrGTddSqs+W4NYYGFODLF+VrtaIOGHSAj6W+xno1g=";
  };

  propagatedBuildInputs = [
    twisted passlib pyopenssl pyparsing service-identity zope_interface
  ];

  disabled = !isPy3k;

  # see 96a514a232c866ffc044c88214390ee30bd6804b
  doCheck = false;

  meta = {
    description = "A Pure-Python Twisted library for LDAP";
    homepage = "https://github.com/twisted/ldaptor";
    license = lib.licenses.mit;
  };
}
