{ lib
, buildPythonPackage
, fetchPypi
}:

buildPythonPackage rec {
  pname = "ago";
  version = "0.0.93";

  src = fetchPypi {
    inherit pname version;
    sha256 = "9d1956edd8103c266d968ae2a7eaf2f23470b6384e655aaaf54d1158408178ad";
  };

  meta = with lib; {
    description = "Ago: Human readable timedeltas";
    homepage = https://bitbucket.org/russellballestrini/ago/src;
    license = licenses.publicDomain;
    maintainers = [ maintainers.lheckemann ];
  };
}
