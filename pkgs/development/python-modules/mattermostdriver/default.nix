{ lib
, buildPythonPackage
, fetchPypi
, pythonOlder
, websockets
, requests
}:

buildPythonPackage rec {
  pname = "mattermostdriver";
  version = "7.0.1";

  disabled = pythonOlder "3.5";

  src = fetchPypi {
    inherit pname version;
    sha256 = "2d880366a9a19f0476edc498bd808b43261fa0b04dd3f7207a0cec3c59bb79c5";
  };

  propagatedBuildInputs = [ websockets requests ];

  meta = with lib; {
    description = "A Python Mattermost Driver";
    homepage = https://github.com/Vaelor/python-mattermost-driver;
    license = licenses.mit;
    maintainers = [ maintainers.lheckemann ];
  };
}
