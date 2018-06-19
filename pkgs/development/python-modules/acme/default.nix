{ stdenv, buildPythonPackage, fetchPypi
, certbot
, pytest
, cryptography
, pyasn1
, pyopenssl
, pyRFC3339
, josepy
, pytz
, requests
, six
, werkzeug
, mock
, ndg-httpsclient
, requests-toolbelt
}:

buildPythonPackage rec {
  inherit (certbot) src version;

  pname = "acme";
  name = "${pname}-${version}";

  propagatedBuildInputs = [
    cryptography pyasn1 pyopenssl pyRFC3339 pytz requests six werkzeug
    ndg-httpsclient josepy requests-toolbelt
  ];

  checkInputs = [ pytest mock ];

  postUnpack = "sourceRoot=\${sourceRoot}/acme";
}
