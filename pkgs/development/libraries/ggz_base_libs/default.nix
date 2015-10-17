{ stdenv, fetchurl, intltool, libssl, expat, libgcrypt }:

stdenv.mkDerivation rec {
  version = "0.99.5";
  baseName = "ggz-base-libs";
  name = "${baseName}-snapshot-${version}";

  src = fetchurl {
    url = "http://mirrors.ibiblio.org/pub/mirrors/ggzgamingzone/ggz/snapshots/${name}.tar.gz";
    sha256 = "1cw1vg0fbj36zyggnzidx9cbjwfc1yr4zqmsipxnvns7xa2awbdk";
  };

  buildInputs = [ intltool libssl expat libgcrypt ];

  configureFlags = [
    "--with-ssl-dir=${libssl}/"
    "--with-tls"
  ];

  meta = with stdenv.lib; {
    description = "GGZ Gaming zone libraries";
    maintainers = with maintainers;
    [
      raskin
    ];
    platforms = platforms.linux;
    license = licenses.gpl2;
    downloadPage = "http://www.ggzgamingzone.org/releases/";
  };
}
