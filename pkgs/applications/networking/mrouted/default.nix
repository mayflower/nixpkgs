{ stdenv, fetchFromGitHub, bison }:

stdenv.mkDerivation rec {
  pname = "mrouted";
  version = "3.9.8";

  # needs submodules
  src = fetchFromGitHub {
    owner = "troglobit";
    repo = pname;
    rev = version;
    sha256 = "00x3dn4lldlhyblh6ir3jklpbg5595vqmym1g2164ibqlgrhj5bh";
  };

  nativeBuildInputs = [ bison ];

  dontAddPrefix = true;
  makeFlags = [ "prefix=${placeholder "out"}" "sysconfdir=${placeholder "out"}/etc" ];

  meta = with stdenv.lib; {
    description = "Simple Multicast Routing for UNIX";
    inherit (src.meta) homepage;
    license = licenses.free;
    maintainer = with maintainers; [ globin ];
    platforms = platforms.unix;
  };
}
