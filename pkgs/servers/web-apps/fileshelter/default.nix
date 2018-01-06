{ stdenv, fetchFromGitHub, autoreconfHook, libzip, boost, wt, libconfig, pkgconfig } :

stdenv.mkDerivation rec {
  name = "fileshelter";
  version = "3.0.0";

  src = fetchFromGitHub {
    owner = "epoupon";
    repo = "fileshelter";
    rev = "v${version}";
    sha256 = "1n9hrls3l9gf8wfz6m9bylma1b1hdvdqsksv2dlp1zdgjdzv200b";
  };

  nativeBuildInputs = [ autoreconfHook pkgconfig ];
  buildInputs = [ libzip boost wt libconfig ];

  postInstall = ''
    ln -s ${wt}/share/Wt/resources $out/share/fileshelter/docroot/resources
  '';

  meta = with stdenv.lib; {
    homepage = https://github.com/epoupon/fileshelter;
    description = "FileShelter is a 'one-click' file sharing web application";
    maintainers = [ maintainers.willibutz ];
    license = licenses.gpl3;
    platforms = platforms.linux;
  };
}
