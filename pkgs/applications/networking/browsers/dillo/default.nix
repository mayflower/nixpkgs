{ stdenv, fetchurl
, fltk
, libssl
, libjpeg, libpng
, perl
, libXcursor, libXi, libXinerama }:

stdenv.mkDerivation rec {
  version = "3.0.5";
  name = "dillo-${version}";

  src = fetchurl {
    url = "http://www.dillo.org/download/${name}.tar.bz2";
    sha256 = "12ql8n1lypv3k5zqgwjxlw1md90ixz3ag6j1gghfnhjq3inf26yv";
  };

  buildInputs = with stdenv.lib;
  [ perl fltk libssl libjpeg libpng libXcursor libXi libXinerama ];

  configureFlags =  "--enable-ssl";

  meta = with stdenv.lib; {
    homepage = http://www.dillo.org/;
    description = "A fast graphical web browser with a small footprint";
    longDescription = ''
      Dillo is a small, fast web browser, tailored for older machines.
    '';
    maintainers = [ maintainers.AndersonTorres ];
    platforms = platforms.linux;
  };
}
