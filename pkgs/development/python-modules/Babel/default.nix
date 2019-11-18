{ lib, buildPythonPackage, fetchPypi, pytz, pytest, freezegun, glibcLocales }:

buildPythonPackage rec {
  pname = "Babel";
  version = "2.7.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0a7wawx8vsg7igvz6p3x909fskhg4b2y1910xk4f4c8y22p3aqg8";
  };

  propagatedBuildInputs = [ pytz ];

  checkInputs = [ pytest freezegun glibcLocales ];

  preCheck = ''
    export LC_ALL="en_US.UTF-8"
  '';

  meta = with lib; {
    homepage = http://babel.edgewall.org;
    description = "A collection of tools for internationalizing Python applications";
    license = licenses.bsd3;
    maintainers = with maintainers; [ ];
  };
}
