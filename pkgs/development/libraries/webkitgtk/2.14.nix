{ stdenv, fetchurl, perl, python2, ruby, bison, gperf, cmake
, pkgconfig, gettext, gobjectIntrospection, libnotify, gnutls
, gtk2, gtk3, wayland, libwebp, enchant, xlibs, libxkbcommon, epoxy, at_spi2_core
, libxml2, libsoup, libsecret, libxslt, harfbuzz, libpthreadstubs
, enableGeoLocation ? true, geoclue2, sqlite, pcre
, gst-plugins-base
}:

assert enableGeoLocation -> geoclue2 != null;

with stdenv.lib;
stdenv.mkDerivation rec {
  name = "webkitgtk-${version}";
  version = "2.14.2";

  meta = {
    description = "Web content rendering engine, GTK+ port";
    homepage = "http://webkitgtk.org/";
    license = licenses.bsd2;
    platforms = platforms.linux;
    hydraPlatforms = [];
    maintainers = with maintainers; [ ];
  };

  preConfigure = "patchShebangs Tools";

  src = fetchurl {
    url = "http://webkitgtk.org/releases/${name}.tar.xz";
    sha256 = "0mjmcxhafh6l6j062z2nwfqbbvfyx16iqrzrbajswijh23awpnrf";
  };

  # see if we can clean this up....

  patches = [ ./finding-harfbuzz-icu.patch ];

  cmakeFlags = [
  "-DPORT=GTK"
  "-DUSE_LIBHYPHEN=0"
  "-DENABLE_GLES2=ON"
  ];

  # XXX: WebKit2 missing include path for gst-plugins-base.
  # Filled: https://bugs.webkit.org/show_bug.cgi?id=148894
  NIX_CFLAGS_COMPILE = "-I${gst-plugins-base.dev}/include/gstreamer-1.0";

  nativeBuildInputs = [
    cmake perl python2 ruby bison gperf sqlite
    pkgconfig gettext gobjectIntrospection
  ];

  buildInputs = [
    gtk2 wayland libwebp enchant libnotify gnutls
    libxml2 libsecret libxslt harfbuzz libpthreadstubs
    gst-plugins-base libxkbcommon epoxy at_spi2_core pcre
  ] ++ optional enableGeoLocation geoclue2
    ++ (with xlibs; [ libXdmcp libXt libXtst ]);

  propagatedBuildInputs = [
    libsoup gtk3
  ];

  enableParallelBuilding = true;
}
