{ lib, buildPythonPackage, fetchPypi, cffi, olm, future, isPy3k
}:

buildPythonPackage rec {
  pname = "python-olm-dev";
  version = "3.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1q8kxa3p7mcn265zzx57385p10z9qxcxcb24x0xi214wcbv7mrnf";
  };

  buildInputs = [ olm ];
  propagatedBuildInputs = [ cffi future ];

  postPatch = lib.optionalString (!isPy3k) ''
    sed -i /typing/d setup.py
  '';

  meta = with lib; {
    description = "Python CFFI bindings for the olm cryptographic ratchet library";
    license = licenses.asl20;
    homepage = https://github.com/poljar/python-olm;
    maintainers = with maintainers; [ globin ];
  };
}
