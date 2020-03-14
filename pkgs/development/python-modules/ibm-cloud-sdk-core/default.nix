{ lib
, buildPythonPackage
, fetchPypi
, responses
, pytest
, pytest-rerunfailures
, tox
, pylint
#, bumpversion
, requests
, python-dateutil
, pyjwt
}:

buildPythonPackage rec {
  pname = "ibm-cloud-sdk-core";
  version = "1.7.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "9f1d107911cbc5ae3fd04149f5f1b7257aec4cd8fa7fdc69bc0491aee54365c5";
  };

  # # Package conditions to handle
  # # might have to sed setup.py and egg.info in patchPhase
  # # sed -i "s/<package>.../<package>/"
  # requests>=2.0, <3.0
  # python_dateutil>=2.5.3
  # PyJWT >=1.7.1
  checkInputs = [
    responses
    pytest
    pytest-rerunfailures
    tox
    pylint
  ];

  propagatedBuildInputs = [
    requests
    python-dateutil
    pyjwt
  ];

  # Various tests try to access credential files which are not included with the source distribution
  checkPhase = let brokenTests = [
    "test_iam" "test_files" "test_cwd" "test_configure_service" "test_get_authenticator"
    "test_vcap_credentials" "test_multi_word_service_name"
  ]; in ''
    pytest -k 'not ${lib.concatStringsSep " and not " brokenTests }'
  '';

  meta = with lib; {
    description = "Client library for the IBM Cloud services";
    homepage = https://github.com/IBM/python-sdk-core;
    license = licenses.asl20;
    maintainers = [ maintainers.lheckemann ];
  };
}
