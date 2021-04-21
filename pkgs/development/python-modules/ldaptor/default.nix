{ lib
, buildPythonPackage
, fetchPypi
, twisted
, passlib
, pycrypto
, pyopenssl
, pyparsing
, service-identity
, zope_interface
, isPy3k
}:

buildPythonPackage rec {
  pname = "ldaptor";
  version = "21.2.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0n53czn5pyh8923y282spdb7xc8c9rhn0n43bczanjjx6wcynjcc";
  };

  propagatedBuildInputs = [
    twisted passlib pycrypto pyopenssl pyparsing service-identity zope_interface
  ];

  meta = {
    description = "A Pure-Python Twisted library for LDAP";
    homepage = "https://github.com/twisted/ldaptor";
    license = lib.licenses.mit;
  };
}
