{ stdenv, fetchurl, autoconf, vala, pkgconfig, glib, gobject-introspection, gnome3 }:

stdenv.mkDerivation rec {
  pname = "libgee";
  version = "0.20.1";

  src = fetchurl {
    url = "mirror://gnome/sources/${pname}/${stdenv.lib.versions.majorMinor version}/${pname}-${version}.tar.xz";
    sha256 = "0c26x8gi3ivmhlbqcmiag4jwrkvcy28ld24j55nqr3jikb904a5v";
  };

  doCheck = true;

  nativeBuildInputs = [ pkgconfig autoconf vala gobject-introspection ];
  buildInputs = [ glib ];

  passthru = {
    updateScript = gnome3.updateScript {
      packageName = pname;
    };
  };

  meta = with stdenv.lib; {
    description = "Utility library providing GObject-based interfaces and classes for commonly used data structures";
    homepage = https://wiki.gnome.org/Projects/Libgee;
    license = licenses.lgpl21Plus;
    platforms = platforms.unix;
    maintainers = gnome3.maintainers;
  };
}
