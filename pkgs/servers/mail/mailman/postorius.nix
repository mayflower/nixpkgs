{ stdenv, fetchFromGitLab, fetchpatch, python3 }:

python3.pkgs.buildPythonApplication rec {
  name = "postorius-${version}";
  version = "1.1.0";

  src = fetchFromGitLab {
    owner = "mailman";
    repo = "postorius";
    rev = version;
    sha256 = "1lg8p2kgxn0qwv38c1dary4zss64hqpl8a1dq0diaj8y2jn5mai2";
  };

  propagatedBuildInputs = with python3.pkgs; [
    mailmanclient django django-mailman3 beautifulsoup4 vcrpy mock
  ];

  doCheck = false;

  patches = [
    (fetchpatch {
      url = "https://gitlab.com/mailman/postorius/merge_requests/74.patch";
      sha256 = "00h5psnws16p3vs4mmnp8zyv2q5nax7wd2naxix6f7imyxhsajbz";
      excludes = [ "tox.ini" ];
    })
  ];

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
