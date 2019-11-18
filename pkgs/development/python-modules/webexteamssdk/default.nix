{ lib, buildPythonPackage, fetchPypi
, future, requests-toolbelt, pyjwt
}:

buildPythonPackage rec {
  pname = "webexteamssdk";
  version = "1.2";

  src = fetchPypi {
    inherit pname version;
    sha256 = "03n3bw8hq8lfg3jx89ggzv5bgk9w6z0c8qh8dsbizjlsl8jysrqf";
  };

  propagatedBuildInputs = [
    future requests-toolbelt pyjwt
  ];

  # no tests in archive
  doCheck = false;

  meta = with lib; {
    description = "Work with the Webex Teams APIs in native Python!";
    license = licenses.mit;
    homepage = https://webexteamssdk.readthedocs.io/;
    maintainers = with maintainers; [ globin ];
  };
}
