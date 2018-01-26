{ stdenv, fetchFromGitLab, fetchpatch, python3 }:

python3.pkgs.buildPythonApplication rec {
  name = "postorius-${version}";
  version = "1.1.1";

  src = fetchFromGitLab {
    owner = "globin";
    repo = "postorius";
    rev = "884a8bf24396d1aafcbe70985f0465e1e4121d09";
    sha256 = "0zl0syi2f9gdilc8vp3vgdavz75dbaagq1rdsgj8ldddkzdylnd6";
  };

  propagatedBuildInputs = with python3.pkgs; [
    mailmanclient django django-mailman3 beautifulsoup4 vcrpy mock psycopg2
  ];

  postPatch = ''
    substituteInPlace src/postorius/templatetags/membership_helpers.py \
      --replace "._client" ""
  '';

  postInstall = ''
    mkdir -p $out/share/postorius
    cp -R . $out/share/postorius
  '';

  checkPhase = ''
    cd $NIX_BUILD_TOP/$sourceRoot
    PYTHONPATH=.:$PYTHONPATH python example_project/manage.py test --settings=test_settings postorius
  '';

  meta = {
    homepage = "http://www.gnu.org/software/mailman/";
    description = "Web UI for GNU Mailman";
    license = stdenv.lib.licenses.gpl3;
    platforms = stdenv.lib.platforms.linux;
    maintainers = [ stdenv.lib.maintainers.globin ];
  };
}
