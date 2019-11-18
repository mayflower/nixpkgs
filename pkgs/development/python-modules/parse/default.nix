{ stdenv, fetchPypi
, buildPythonPackage, python
}:
buildPythonPackage rec {
  pname = "parse";
  version = "1.12.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "05ypj14kdzhpgkqgka6s8ig3pq7w3grg6a2wqrxxg2351h0agz55";
  };

  checkPhase = ''
    ${python.interpreter} test_parse.py
  '';

  meta = with stdenv.lib; {
    homepage = https://github.com/r1chardj0n3s/parse;
    description = "parse() is the opposite of format()";
    license = licenses.bsdOriginal;
    maintainers = with maintainers; [ alunduil ];
  };
}
