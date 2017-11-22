{ stdenv, fetchFromGitLab, fetchpatch, python3 }:

python3.pkgs.buildPythonApplication rec {
  name = "postorius-${version}";
  version = "1.1.1";

  src = fetchFromGitLab {
    owner = "mailman";
    repo = "postorius";
    rev = version;
    sha256 = "19d9lckp866w1l0hfkv4w3bl1d5ar2ahrnj1ms5agid2rjv2pcc7";
  };

  propagatedBuildInputs = with python3.pkgs; [
    mailmanclient django django-mailman3 beautifulsoup4 vcrpy mock psycopg2
  ];

  doCheck = false;

  patches = [
    (fetchpatch {
      url = "https://gitlab.com/mailman/postorius/merge_requests/74.patch";
      sha256 = "158a8zkm0x8x5c6bhrc22f8i3zyaasqflcv7z1cys3j189f7sizr";
      excludes = [ "tox.ini" ".gitlab-ci.yml" ];
    })
  ];

  postPatch = ''
    substituteInPlace src/postorius/templatetags/membership_helpers.py \
      --replace "._client" ""
  '';

  postInstall = ''
    mkdir -p $out/share/postorius
    cp -R . $out/share/postorius
  '';

  meta = {
    homepage = "http://www.gnu.org/software/mailman/";
    description = "Web UI for GNU Mailman";
    license = stdenv.lib.licenses.gpl3;
    platforms = stdenv.lib.platforms.linux;
    maintainers = [ stdenv.lib.maintainers.globin ];
  };
}
