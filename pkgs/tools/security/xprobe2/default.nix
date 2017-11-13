{ stdenv, fetchurl, libpcap }:

stdenv.mkDerivation rec {
  name = "${pname}-${version}";
  pname = "xprobe2";
  version = "0.3";

  src = fetchurl {
    url = "mirror://sourceforge/project/xprobe/xprobe2/Xprobe2%200.3/${name}.tar.gz";
    sha256 = "0r51g6xigm5g98w4i2azyln660lq06r9dkg1r5sbpa4dyfid1a8j";
  };

  buildInputs = [ libpcap ];

  postPatch = ''
    sed -i '1i#include <string.h>' libs-external/USI++/usi++/tcp.h
  '';

  meta = with stdenv.lib; {
    description = "A remote active operating system fingerprinting tool";
    license = licenses.gpl2Plus;
    maintainers = [ maintainers.globin ];
    platforms = platforms.all;
    homepage = "https://sourceforge.net/projects/xprobe";
  };
}
