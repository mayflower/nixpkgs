{ stdenv
, buildPythonPackage
, fetchPypi
}:

buildPythonPackage rec {
  pname = "watchgod";
  version = "0.6";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0n38ijbg8wz4rrv5kgjfy2ph1zsnh78qpzgrbp47zwb3kjms1k79";
  };

  # no tests in release
  doCheck = false;

  meta = with stdenv.lib; {
    description = "Simple, modern file watching and code reload in python";
    homepage = "https://github.com/samuelcolvin/watchgod";
    license = licenses.mit;
    maintainers = with maintainers; [ globin ];
  };

}
