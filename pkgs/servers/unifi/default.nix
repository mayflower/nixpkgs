{ stdenv
, dpkg
, fetchurl
, unzip
}:

stdenv.mkDerivation rec {
  name = "unifi-controller-${version}";
  version = "5.6.24";

  src = fetchurl {
    url = "https://dl.ubnt.com/unifi/5.6.24-e2998a5aab/unifi_sysvinit_all.deb";
    sha256 = "0r885ik1dad0ci0ll49w9n7rmmnyf7ppk4g6sfvyj7fs0a5vw8ci";
  };

  buildInputs = [ dpkg ];

  unpackPhase = ''
    dpkg-deb -x ${src} ./
  '';

  doConfigure = false;

  installPhase = ''
    mkdir -p $out
    cd ./usr/lib/unifi
    cp -ar dl lib webapps $out
  '';

  meta = with stdenv.lib; {
    homepage = http://www.ubnt.com/;
    description = "Controller for Ubiquiti UniFi accesspoints";
    license = licenses.unfree;
    platforms = platforms.unix;
    maintainers = with maintainers; [ wkennington fpletz ];
  };
}
