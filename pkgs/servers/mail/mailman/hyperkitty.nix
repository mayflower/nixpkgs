{ stdenv, fetchFromGitLab, python3 }:

python3.pkgs.buildPythonApplication rec {
  name = "hyperkitty-${version}";
  version = "1.1.4";

  src = fetchFromGitLab {
    owner = "globin";
    repo = "hyperkitty";
    rev = "bd60e4efc63b14286a3484807c90e8fa0c7de64d";
    sha256 = "0cbcrv699k4wa1z8m7qrp9hm72rqkv2bya2l9d7y5lcqz34ng5kp";
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
