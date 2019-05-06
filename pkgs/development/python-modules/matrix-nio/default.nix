{ lib, buildPythonPackage, fetchPypi, isPy3k, unpaddedbase64
, pycryptodome, peewee, jsonschema, attrs, python-olm-dev
, h2, h11, atomicwrites, Logbook
}:

buildPythonPackage rec {
  pname = "matrix-nio";
  version = "0.2";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1fklqswxwwkjnvi0lv8yhfs89zqlm8j04iiv06c8ln7v45nwnj0h";
  };

  propagatedBuildInputs = [
    unpaddedbase64 pycryptodome peewee jsonschema attrs
    python-olm-dev h2 h11 atomicwrites Logbook
  ];

  postPatch = lib.optionalString (!isPy3k) ''
    sed -i /typing/d setup.py
  '';

  meta = with lib; {
    description = "A Python Matrix client library, designed according to sans I/O principles ";
    license = licenses.isc;
    homepage = https://github.com/poljar/matrix-nio;
    maintainers = with maintainers; [ globin ];
  };
}
