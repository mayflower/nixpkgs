{ stdenv, fetchFromGitLab, fetchpatch, python3 }:

python3.pkgs.buildPythonApplication rec {
  name = "postorius-${version}";
  version = "1.1.1";

  src = fetchFromGitLab {
    owner = "globin";
    repo = "postorius";
    rev = "fb6fbe891f022ccc5fa2aad1e8ef3577d7b50ffb";
    sha256 = "0jfcpb2781aqgiyzavxv58sn783pg75vmjlaczkpj4xpaszbffjs";
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
