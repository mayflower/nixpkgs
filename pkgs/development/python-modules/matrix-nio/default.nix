{ lib, buildPythonPackage, fetchPypi, isPy3k, unpaddedbase64
, pycryptodome, peewee, jsonschema, attrs, olm, future
, h2, h11, atomicwrites, Logbook, aiohttp, cachetools
}:

buildPythonPackage rec {
  pname = "matrix-nio";
  version = "0.6";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0l7gw3hkmk79pfk5nifb4pg6miis8mmrlvjvbigh6d8lbsfsr915";
  };

  propagatedBuildInputs = [
    unpaddedbase64 pycryptodome peewee jsonschema attrs
    olm h2 h11 atomicwrites Logbook aiohttp
    cachetools future
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
