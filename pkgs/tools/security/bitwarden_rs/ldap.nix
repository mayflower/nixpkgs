{ stdenv, rustPlatform, fetchFromGitHub, pkgconfig, openssl }:

rustPlatform.buildRustPackage rec {
  pname = "bitwarden_rs_ldap";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "ViViDboarder";
    repo = pname;
    rev = "v${version}";
    sha256 = "05fy558nngpl5f5d9h40qsz1jxqklsm5q9ai8kr45l6qvq8wxqij";
  };

  nativeBuildInputs = [ pkgconfig ];
  buildInputs = [ openssl ];

  cargoSha256 = "1ciaq6743q1vv1r52v9sp0x627jgycxw4qsxgbq8pbzhss6f71dp";

  meta = with stdenv.lib; {
    description = "LDAP directory connector for bitwarden_rs";
    homepage = "https://github.com/ViViDboarder/bitwarden_rs_ldap";
    license = licenses.gpl3;
    maintainers = with maintainers; [ globin ];
    platforms = platforms.all;
  };
}
