{ stdenv, fetchFromGitHub, rustPlatform, makeWrapper, openssl }:

with rustPlatform;

buildRustPackage rec {
  name = "cfdyndns-${version}";
  version = "0.0.1";
  src = fetchFromGitHub {
    owner = "colemickens";
    repo = "cfdyndns";
    rev = "v${version}";
    sha256 = "1mcdjykrgh0jq6k6y664lai8sbgzk6j7k0r944f43vg63d1jql5b";
  };

  cargoSha256 = "13m7q7d0mr9k22v756mmvhbsp9hcc4y9bklj88yzc2ja881casaw";

  buildInputs = [ makeWrapper openssl ];

  installPhase = ''
    mkdir -p $out/bin
    cp -p target/release/cfdyndns $out/bin/
  '';

  meta = with stdenv.lib; {
    description = "CloudFlare Dynamic DNS Client";
    homepage = https://github.com/colemickens/cfdyndns;
    license = stdenv.lib.licenses.mit;
    maintainers = with maintainers; [ colemickens ];
    platforms = with platforms; linux;
  };
}
