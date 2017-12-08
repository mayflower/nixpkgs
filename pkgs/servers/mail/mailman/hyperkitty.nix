{ stdenv, fetchFromGitLab, python3 }:

python3.pkgs.buildPythonApplication rec {
  name = "hyperkitty-${version}";
  version = "1.1.4";

  src = fetchFromGitLab {
    owner = "globin";
    repo = "hyperkitty";
    rev = "b26bcb030fb460564494d301f8f9bfc5ddbc0e26";
    sha256 = "0ybz9dnq8dmhr04wplmcnld2jwd2pa6p0nl3f5mch1q4dsky06d8";
  };

  propagatedBuildInputs = with python3.pkgs; [
    robot-detection django_extensions rjsmin cssmin django-mailman3
    django-haystack lockfile networkx dateutil defusedxml
    django-paintstore djangorestframework django django-q
    django_compressor beautifulsoup4 six psycopg2
  ];

  buildInputs = with python3.pkgs; [ coverage mock ];

  doCheck = false;

  postPatch = ''
    sed -i 's/Django<1.11/Django/' setup.py
  '';

  meta = {
    homepage = "http://www.gnu.org/software/mailman/";
    description = "Archiver for GNU Mailman v3";
    license = stdenv.lib.licenses.gpl3;
    platforms = stdenv.lib.platforms.linux;
    maintainers = [ stdenv.lib.maintainers.globin ];
  };
}
