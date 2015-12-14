{ stdenv, fetchurl, alsaLib }:
stdenv.mkDerivation rec {
  name = "multimidicast";
  version = "1.3";

  src = fetchurl {
    url = "http://llg.cubic.org/tools/multimidicast/multimidicast-${version}.tar.gz";
    sha256 = "0m450nmlwz5645b1c73a77nca2nf4k5d1g8rmml0k4vv8kqdq5bh";
  };

  buildInputs = [ alsaLib ];

  patches = [ ./fix.patch ];

  installPhase = ''
    mkdir -p $out/bin
    install multimidicast $out/bin
  '';
}
