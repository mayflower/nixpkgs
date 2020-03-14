{ lib
, buildPythonPackage
, fetchPypi
, responses
, pytest
, python-dotenv
, pytest-rerunfailures
, tox
, requests
, python-dateutil
, websocket_client
, ibm-cloud-sdk-core
}:

buildPythonPackage rec {
  pname = "ibm-watson";
  version = "4.3.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "e63aa9cba00d0b00eba82c78a40caf62876001b75dacb5ab7244023367894774";
  };

  # # Package conditions to handle
  # # might have to sed setup.py and egg.info in patchPhase
  # # sed -i "s/<package>.../<package>/"
  # requests>=2.0, <3.0
  # python_dateutil>=2.5.3
  # websocket-client==0.48.0
  # ibm_cloud_sdk_core==1.5.1
  checkInputs = [
    responses
    pytest
    python-dotenv
    pytest-rerunfailures
    tox
  ];

  propagatedBuildInputs = [
    requests
    python-dateutil
    websocket_client
    ibm-cloud-sdk-core
  ];

  doCheck = false; # no tests discovered for some reason
  checkPhase = ''
    pytest
  '';

  postPatch = ''
    substituteInPlace setup.py \
      --replace websocket-client==0.48.0 websocket-client>=0.48.0 \
      --replace ibm_cloud_sdk_core==1.5.1 ibm_cloud_sdk_core>=1.5.1
  '';

  meta = with lib; {
    description = "Client library to use the IBM Watson Services";
    homepage = https://github.com/watson-developer-cloud/python-sdk;
    license = licenses.asl20;
    maintainers = [ maintainers.lheckemann ];
  };
}
