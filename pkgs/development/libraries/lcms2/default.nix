{ lib, stdenv, fetchurl, libtiff, libjpeg, zlib }:

stdenv.mkDerivation rec {
  pname = "lcms2";
  version = "2.15";

  src = fetchurl {
    url = "mirror://sourceforge/lcms/${pname}-${version}.tar.gz";
    sha256 = "sha256-sgy8vQ9QNDO+Kk6BRiEG+mEFCjUHTcJKTjVnktlxqzk=";
  };

  outputs = [ "bin" "dev" "out" ];

  propagatedBuildInputs = [ libtiff libjpeg zlib ];

  # See https://trac.macports.org/ticket/60656
  env.LDFLAGS = lib.optionalString stdenv.hostPlatform.isDarwin "-Wl,-w";

  meta = with lib; {
    description = "Color management engine";
    homepage = "http://www.littlecms.com/";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
