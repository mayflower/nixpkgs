{ lib, buildPythonPackage, fetchPypi, setuptools_scm
, tempora, six, pytest, python
}:

buildPythonPackage rec {
  pname = "jaraco.logging";
  version = "2.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1lb846j7qs1hgqwkyifv51nhl3f8jimbc4lk8yn9nkaynw0vyzcg";
  };

  patches = [ ./0001-Don-t-run-flake8-checks-during-the-build.patch ];

  buildInputs = [ setuptools_scm ];
  propagatedBuildInputs = [ tempora six ];
  checkInputs = [ pytest ];

  checkPhase = ''
    PYTHONPATH=".:$PYTHONPATH" pytest
  '';
  postInstall = ''
    rm -f $out/${python.sitePackages}/jaraco/__pycache__/__init__.*.pyc
  '';

  meta = with lib; {
    description = "Support for Python logging facility";
    homepage = https://github.com/jaraco/jaraco.logging;
    license = licenses.mit;
  };
}
