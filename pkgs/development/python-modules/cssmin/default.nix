{ stdenv, buildPythonPackage, fetchPypi }:

buildPythonPackage rec {
  pname = "cssmin";
  name = "${pname}-${version}";
  version = "0.2.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1dk723nfm2yf8cp4pj785giqlwv42l0kj8rk40kczvq1hk6g04p0";
  };

  # no tests
  doCheck = false;
  
  meta = with stdenv.lib; {
    description = "A Python port of the YUI CSS compression algorithm";
    homepage = http://github.com/zacharyvoase/cssmin;
    license = licenses.bsd3;
  };
}
