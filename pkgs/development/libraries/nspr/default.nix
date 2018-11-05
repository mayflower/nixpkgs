{ stdenv, fetchurl, buildPackages
, CoreServices ? null }:

let version = "4.19"; in

stdenv.mkDerivation {
  name = "nspr-${version}";

  src = fetchurl {
    url = "mirror://mozilla/nspr/releases/v${version}/src/nspr-${version}.tar.gz";
    sha256 = "0agpv3f17h8kmzi0ifibaaxc1k3xc0q61wqw3l6r2xr2z8bmkn9f";
  };

  outputs = [ "out" "dev" ];
  outputBin = "dev";

  preConfigure = ''
    cd nspr
    substituteInPlace configure.in --replace '$host' '$build'
  '' + stdenv.lib.optionalString stdenv.isDarwin ''
    substituteInPlace configure --replace '@executable_path/' "$out/lib/"
    substituteInPlace configure.in --replace '@executable_path/' "$out/lib/"
  '';

  configureFlags = [
    "--enable-optimize"
    "--disable-debug"
  ] ++ stdenv.lib.optional stdenv.is64bit "--enable-64bit";

  postInstall = ''
    find $out -name "*.a" -delete
    moveToOutput share "$dev" # just aclocal
  '';

  # upstream misnomer
  HOST_CC = "${buildPackages.stdenv.cc}/bin/cc";
  depsBuildBuild = [ buildPackages.stdenv.cc ];
  buildInputs = stdenv.lib.optional stdenv.isDarwin CoreServices;

  enableParallelBuilding = true;

  meta = {
    homepage = http://www.mozilla.org/projects/nspr/;
    description = "Netscape Portable Runtime, a platform-neutral API for system-level and libc-like functions";
    platforms = stdenv.lib.platforms.all;
  };
}
