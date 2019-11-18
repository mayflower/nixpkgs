{ lib, buildPythonPackage, fetchPypi
}:

buildPythonPackage rec {
  pname = "hiredis";
  version = "1.0.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256:194pgbb4k0wffxqzfr9jzffkcpcx88a0221dzkj6swrzpdixsnda";
  };

  # no tests on pypi
  doCheck = false;

  meta = with lib; {
    description = "Python extension that wraps protocol parsing code in hiredis";
    license = licenses.bsd3;
    homepage = https://github.com/poljar/matrix-nio;
    maintainers = with maintainers; [ globin ];
  };
}
