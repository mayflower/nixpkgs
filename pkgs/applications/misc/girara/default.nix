{ stdenv, fetchurl, meson, ninja, pkgconfig, glib, gtk, gettext, ncurses, libiconv, libintlOrEmpty
}:

stdenv.mkDerivation rec {
  name = "girara-${version}";
  version = "0.2.9";

  src = fetchurl {
    url = "http://pwmt.org/projects/girara/download/${name}.tar.xz";
    sha256 = "0lkxrfna818wkkr2f6mdzf15y5z8xl1b9592ylmzjbqsqya3w7x8";
  };

  nativeBuildInputs = [ meson ninja pkgconfig gettext ];
  buildInputs = [ libintlOrEmpty ]
    ++ stdenv.lib.optional stdenv.isDarwin libiconv;
  propagatedBuildInputs = [ glib gtk ];

  NIX_LDFLAGS = stdenv.lib.optionalString stdenv.isDarwin "-lintl";

  meta = with stdenv.lib; {
    homepage = https://pwmt.org/projects/girara/;
    description = "User interface library";
    longDescription = ''
      girara is a library that implements a GTK+ based VIM-like user interface
      that focuses on simplicity and minimalism.
    '';
    license = licenses.zlib;
    platforms = platforms.linux ++ platforms.darwin;
    maintainers = [ maintainers.garbas ];
  };
}
