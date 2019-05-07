{ stdenv, fetchurl, fetchpatch }:

stdenv.mkDerivation rec {
  name = "nextcloud-${version}";
  version = "16.0.0";

  src = fetchurl {
    url = "https://download.nextcloud.com/server/releases/${name}.tar.bz2";
    sha256 = "0bj014vczlrql1w32pqmr7cyqn9awnyzpi2syxhg16qxic1gfcj5";
  };

  installPhase = ''
    mkdir -p $out/
    cp -R . $out/
  '';

  meta = {
    description = "Sharing solution for files, calendars, contacts and more";
    homepage = https://nextcloud.com;
    maintainers = with stdenv.lib.maintainers; [ schneefux bachp globin fpletz ];
    license = stdenv.lib.licenses.agpl3Plus;
    platforms = with stdenv.lib.platforms; unix;
  };
}
