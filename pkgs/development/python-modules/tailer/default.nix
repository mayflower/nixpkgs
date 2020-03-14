{ lib
, buildPythonPackage
, fetchPypi
}:

buildPythonPackage rec {
  pname = "tailer";
  version = "0.4.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "78d60f23a1b8a2d32f400b3c8c06b01142ac7841b75d8a1efcb33515877ba531";
  };

  meta = with lib; {
    description = "Python tail is a simple implementation of GNU tail and head";
    homepage = https://github.com/six8/pytailer;
    license = licenses.mit;
    maintainers = [ maintainers.lheckemann ];
  };
}
