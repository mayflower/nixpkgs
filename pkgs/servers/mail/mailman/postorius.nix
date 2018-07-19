{ stdenv, fetchFromGitLab, fetchpatch, python3 }:

python3.pkgs.buildPythonPackage rec {
  name = "postorius-${version}";
  version = "1.1.1-dev";

  src = fetchFromGitLab {
    owner = "mailman";
    repo = "postorius";
    rev = "009ebe132dc99125ef4a5c1761187819e6d7cce8";
    sha256 = "1szmi6cclgn4qc6w6m6g7xwpk249m4b9wlngp7fkys3p6ncw5jdd";
  };

  propagatedBuildInputs = with python3.pkgs; [
    mailmanclient django django-mailman3 beautifulsoup4 vcrpy mock psycopg2
  ];

  patches = [ ./users_can_create_lists.patch ];

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
