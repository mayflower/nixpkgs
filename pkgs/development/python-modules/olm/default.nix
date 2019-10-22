{ lib, pkgs, buildPythonPackage, fetchPypi, cffi, future, isPy3k
}:

let
  inherit (pkgs) olm;
in buildPythonPackage rec {
  pname = "olm";
  version = olm.version;

  src = olm.src;
  postUnpack = "export sourceRoot=$sourceRoot/python";

  buildInputs = [ olm ];

  propagatedBuildInputs = [ cffi future ];

  meta = with lib; {
    description = "Python CFFI bindings for the olm cryptographic ratchet library";
    license = licenses.asl20;
    homepage = https://github.com/poljar/python-olm;
    maintainers = with maintainers; [ globin ];
  };
}
