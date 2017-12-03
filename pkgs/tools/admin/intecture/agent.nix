{ stdenv, lib, fetchFromGitHub, rustPlatform
, openssl, zeromq, czmq, pkgconfig, cmake, zlib }:

with rustPlatform;

buildRustPackage rec {
  name = "intecture-agent-${version}";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "intecture";
    repo = "agent";
    rev = version;
    sha256 = "0b59ij9c7hv2p4jx96f3acbygw27wiv8cfzzg6sg73l6k244k6l6";
  };

  cargoSha256 = "1288jlpig4ipwv0ngi1c7gqflrx4vzahx2bcr7zq846z9m1npd91";

  buildInputs = [ openssl zeromq czmq zlib ];

  nativeBuildInputs = [ pkgconfig cmake ];

  meta = with lib; {
    description = "Authentication client/server for Intecture components";
    homepage = https://intecture.io;
    license = licenses.mpl20;
    maintainers = [ maintainers.rushmorem ];
  };
}
