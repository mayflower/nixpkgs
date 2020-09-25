{ stdenv, fetchgit }:

stdenv.mkDerivation rec {
  pname = "pimd";
  version = "2.3.2";

  # needs submodules
  src = fetchgit {
    url = "https://github.com/troglobit/${pname}";
    rev = version;
    sha256 = "10i5lc0iz2kmbwxmi3bivzj2va9q0ap62sgxhqgch394m20w5427";
  };

  postPatch = ''
    substituteInPlace configure --replace '/bin/echo' 'echo'
  '';

  meta = with stdenv.lib; {
    description = "PIM-SM/SSM multicast routing for UNIX";
    homepage = "https://github.com/troglobit/pimd";
    license = licenses.bsd3;
    maintainer = with maintainers; [ globin ];
    platforms = platforms.unix;
  };
}
