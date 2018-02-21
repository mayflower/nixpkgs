{lib, buildPythonPackage, fetchPypi, fetchpatch, pytest, flake8}:

buildPythonPackage rec {
  name = "${pname}-${version}";
  pname = "pytest-flake8";
  version = "0.9.1";

  # although pytest is a runtime dependency, do not add it as
  # propagatedBuildInputs in order to allow packages depend on another version
  # of pytest more easily
  buildInputs = [ pytest ];
  propagatedBuildInputs = [ flake8 ];

  src = fetchPypi {
    inherit pname version;
    sha256 = "0032l4x2i5qn7ikaaw0kjs9f4ccpas21j564spyxwmx50wnhf5p7";
  };

  patches = [
    # Fix pytest strict mode (pull request #24)
    # https://github.com/tholo/pytest-flake8/pull/24
    (fetchpatch {
      name = "fix-compatibility-with-pytest-strict-mode.patch";
      url = "https://github.com/tholo/pytest-flake8/commit/434e1b07b4b77bfe1ddb9b2b54470c6c3815bb1a.patch";
      sha256 = "0idwgkwwysx2cibnykd81yxrgqzkpf42j99jmpnanqzi99qnc3wx";
    })
  ];

  checkPhase = ''
    pytest .
  '';

  meta = {
    description = "py.test plugin for efficiently checking PEP8 compliance";
    homepage = https://github.com/tholo/pytest-flake8;
    maintainers = with lib.maintainers; [ jluttine ];
    license = lib.licenses.bsd2;
  };
}
