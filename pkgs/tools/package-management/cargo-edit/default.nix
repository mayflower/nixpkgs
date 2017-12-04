{ stdenv, fetchFromGitHub, rustPlatform, makeWrapper, zlib, openssl, pkgconfig }:

with rustPlatform;

buildRustPackage rec {
  name = "cargo-edit-${version}";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "killercup";
    repo = "cargo-edit";
    rev = "v${version}";
    sha256 = "1jxppbb7s50pwg24qxf79fqvm1clwm2zdnv0xlkay7y05nd5bc0c";
  };

  buildInputs = [ zlib openssl pkgconfig ];

  preBuild = ''
    cargo update
  '';

  cargoSha256 = "1cbxlri337fvy8f5vb3bgvd3d44lcvq7hx57ndh3ycm9zyah9i9m";

  meta = with stdenv.lib; {
    description = "A utility for managing cargo dependencies from the command line";
    homepage = https://github.com/killercup/cargo-edit;
    license = with licenses; [ mit ];
    maintainers = with maintainers; [ jb55 ];
    platforms = platforms.all;
  };
}
