{ stdenv, fetchgit, libssl }:

stdenv.mkDerivation rec {
  name = "vfdecrypt";

  src = fetchgit {
    url = git://github.com/drakealleg/VFDecrypt.git;
    rev = "4e2fa32816254907e82886b936afcae9859a876c";
    sha256 = "0b945805f7f60bf48556c2db45c9ab26485fb05acbc6160a563d529b20cb56a3";
  };
  buildInputs = [ libssl ];
  broken = true; # No such repo
  installPhase = ''
    mkdir -p $out/bin
    cp vfdecrypt $out/bin
  '';
}
