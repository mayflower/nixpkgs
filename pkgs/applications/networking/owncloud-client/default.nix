{ stdenv, fetchurl, cmake, pkgconfig, qtbase, qtwebkit, qtkeychain, sqlite }:

stdenv.mkDerivation rec {
  name = "owncloud-client-${version}";
  version = "2.3.4";

  src = fetchurl {
    url = "https://download.owncloud.com/desktop/stable/owncloudclient-${version}.tar.xz";
    sha256 = "1fpi1mlp2b8sx2993b4mava5c6qw794dmlayih430299z1l9wh49";
  };

  patches = [ ../nextcloud-client/find-sql.patch ];

  nativeBuildInputs = [ pkgconfig cmake ];
  buildInputs = [ qtbase qtwebkit qtkeychain sqlite ];

  cmakeFlags = [
    "-UCMAKE_INSTALL_LIBDIR"
  ];

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "Synchronise your ownCloud with your computer using this desktop client";
    homepage = https://owncloud.org;
    maintainers = [ maintainers.qknight ];
    platforms = platforms.unix;
  };
}
