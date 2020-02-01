{ stdenv, buildPythonPackage, fetchPypi, flask, pyjwt, werkzeug, pytest }:

buildPythonPackage rec {
  pname = "Flask-Versioned";
  version = "0.9.4-20101221";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0d7xaw86iv9v58l0kq9ba9802g08hm5342xn5brc86qahvf98rji";
  };

  propagatedBuildInputs = [ flask ];

  # tests not included on pypi
  doCheck = false;

  meta = with stdenv.lib; {
    description = "Flask plugin to rewrite file paths to add version info";
    homepage = https://github.com/pilt/flask-versioned;
    license = licenses.bsd3;
    maintainers = with maintainers; [ globin ];
  };
}
