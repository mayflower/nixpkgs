{ lib, buildPythonPackage, fetchFromGitHub, python-Levenshtein
, hypothesis, pycodestyle, pytest
}:

buildPythonPackage rec {
  pname = "fuzzywuzzy";
  version = "0.16.0";

  src = fetchFromGitHub {
    owner = "seatgeek";
    repo = pname;
    rev = version;
    sha256 = "1fcihbcd7rwv0fbc9sa4389c0ycjkl9bca883dc4fcnfqg4q42h6";
  };

  propagatedBuildInputs = [ python-Levenshtein ];
  checkInputs = [ hypothesis pycodestyle pytest ];

  meta = with lib; {
    description = "Fuzzy String Matching in Python";
    license = licenses.gpl2Plus;
    homepage = https://github.com/seatgeek/fuzzywuzzy;
  };
}
