{ stdenv, fetchFromGitLab, python3 }:

python3.pkgs.buildPythonPackage rec {
  name = "hyperkitty-${version}";
  version = "1.1.5-dev";

  src = fetchFromGitLab {
    owner = "globin";
    repo = "hyperkitty";
    rev = "8718ef2a48633c3551fc050b7b041d94328ce7ed";
    sha256 = "1lmj946l8ksa43cj12fybhavp5gmb4awapb4jm5zhvsh444x9y8w";
  };

  propagatedBuildInputs = with python3.pkgs; [
    robot-detection django_extensions rjsmin cssmin django-mailman3
    django-haystack lockfile networkx dateutil defusedxml
    django-paintstore djangorestframework django django-q
    django_compressor beautifulsoup4 six psycopg2
  ];

  buildInputs = with python3.pkgs; [ coverage mock ];

  doCheck = true;

  postPatch = ''
    sed -i 's/Django<1.11/Django/' setup.py
  '';

  checkPhase = ''
    cd $NIX_BUILD_TOP/$sourceRoot
    PYTHONPATH=.:$PYTHONPATH python example_project/manage.py test \
      --settings=hyperkitty.tests.settings_test hyperkitty
  '';

  meta = {
    homepage = "http://www.gnu.org/software/mailman/";
    description = "Archiver for GNU Mailman v3";
    license = stdenv.lib.licenses.gpl3;
    platforms = stdenv.lib.platforms.linux;
    maintainers = [ stdenv.lib.maintainers.globin ];
  };
}
