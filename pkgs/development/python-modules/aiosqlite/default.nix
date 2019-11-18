{ lib, buildPythonPackage, fetchPypi
}:

buildPythonPackage rec {
  pname = "aiosqlite";
  version = "0.10.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1a925shyvahcjvfvgl86af796p44sr0zq14mg5fhd9vca7bzp15d";
  };

  doCheck = false;

  meta = with lib; {
    description = "asyncio bridge to the standard sqlite3 module";
    license = licenses.mit;
    homepage = https://github.com/jreese/aiosqlite;
    maintainers = with maintainers; [ globin ];
  };
}
