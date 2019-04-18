{ lib, buildPythonPackage, fetchPypi, setuptools_scm
, inflect, more-itertools, six, pytest, python
}:

buildPythonPackage rec {
  pname = "jaraco.itertools";
  version = "4.4.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "d1380ed961c9a4724f0bcca85d2bffebaa2507adfde535d5ee717441c9105fae";
  };

  patches = [ ./0001-Don-t-run-flake8-checks-during-the-build.patch ];

  buildInputs = [ setuptools_scm ];
  propagatedBuildInputs = [ inflect more-itertools six ];
  checkInputs = [ pytest ];

  checkPhase = ''
    pytest
  '';
  postInstall = ''
    rm -f $out/${python.sitePackages}/jaraco/__pycache__/__init__.*.pyc
  '';

  meta = with lib; {
    description = "Tools for working with iterables";
    homepage = https://github.com/jaraco/jaraco.itertools;
    license = licenses.mit;
  };
}
