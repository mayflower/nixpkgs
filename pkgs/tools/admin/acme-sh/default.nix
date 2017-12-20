{ stdenv
, bash, coreutils, curl #diffutils, gawk, gnugrep, gnused
, openssl, socat
, makeWrapper, fetchFromGitHub }:

let
  pkgName = "acme.sh";
  version = "2.7.5";
in
stdenv.mkDerivation rec {
  name = pkgName + "-" + version;

  src = fetchFromGitHub {
    owner = "Neilpang";
    repo = pkgName;
    rev = version;
    sha256 = "0803kjfv9pbiyp9fz1k1r8rnkf2byj8lhh686bvqx3ffh14v2lsc";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin
    cp -a acme.sh $out/bin
    wrapProgram "$out/bin/acme.sh" --prefix PATH : "${
      stdenv.lib.makeBinPath [ openssl coreutils curl socat ]
    }"

    mkdir -p $scripts
    cp -r deploy dnsapi "$scripts"
  '';

  outputs = [ "out" "scripts" ];

  meta = with stdenv.lib; {
    inherit (src.meta) homepage;
    description = "Letsencrypt/acme client implemented as a shell-script";
    license = licenses.mit;
    platforms = platforms.all;
    maintainers = [ maintainers.fpletz ];
  };
}
