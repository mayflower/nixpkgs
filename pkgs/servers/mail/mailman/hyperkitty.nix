{ stdenv, fetchFromGitLab, python3 }:

python3.pkgs.buildPythonApplication rec {
  name = "hyperkitty-${version}";
  version = "1.1.4";

  src = fetchFromGitLab {
    owner = "globin";
    repo = "hyperkitty";
    rev = "bd1ed09e3a714eb85bc5338503e77c3e219420a2";
    sha256 = "08lj9h08pdh7r8h6v655mfdipi3nmn050fva36wjms8h7392c5xy";
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
    sed -i 's/python-dateutil < 2.0/python-dateutil/' setup.py
    sed -i 's/Django<1.11/Django/' setup.py
    sed -i '/enum34/d' setup.py
  '';

  meta = {
    homepage = "http://www.gnu.org/software/mailman/";
    description = "Archiver for GNU Mailman v3";
    license = stdenv.lib.licenses.gpl3;
    platforms = stdenv.lib.platforms.linux;
    maintainers = [ stdenv.lib.maintainers.globin ];
  };
}
