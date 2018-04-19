{ stdenv, fetchFromGitLab, python3 }:

python3.pkgs.buildPythonPackage rec {
  name = "hyperkitty-${version}";
  version = "1.1.5-dev";

  src = fetchFromGitLab {
    owner = "mailman";
    repo = "hyperkitty";
    rev = "917561284e4cd6b863cdfdcfde47d2e3d7f152c7";
    sha256 = "0h5dqpxjir30fyqprm4wlvhg1fwj4f0dzl9zx2rym2d67wjrx92y";
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
