{ stdenv, buildPythonPackage, fetchPypi
, nose, chai, simplejson, backports_functools_lru_cache
, dateutil, pytz, dateparser, mock
}:

buildPythonPackage rec {
  pname = "arrow";
  version = "0.15.2";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0kzjmx0x1gjng48bjcvprbz66j9g70ilha7s9arqva51mdfpq98h";
  };

  checkPhase = ''
    nosetests --cover-package=arrow
  '';

  checkInputs = [ nose chai simplejson pytz dateparser mock ];
  propagatedBuildInputs = [ dateutil backports_functools_lru_cache ];

  meta = with stdenv.lib; {
    description = "Python library for date manipulation";
    license     = "apache";
    maintainers = with maintainers; [ thoughtpolice ];
  };
}
