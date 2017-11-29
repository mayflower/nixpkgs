{ stdenv, buildGoPackage, fetchFromGitHub }:

buildGoPackage rec {
  name = "node_exporter-${version}";
  version = "0.15.0+zfs-fix";
  rev = "e9c629645622808cc268411460ec57a76983da2f";

  goPackagePath = "github.com/prometheus/node_exporter";

  src = fetchFromGitHub {
    inherit rev;
    owner = "mayflower";
    repo = "node_exporter";
    sha256 = "01xxy05g11gim4jzk6cm6kh35yn6gaxqmw8gxxn0jdcg0jgmy6v2";
  };

  # FIXME: megacli test fails
  doCheck = false;

  meta = with stdenv.lib; {
    description = "Prometheus exporter for machine metrics";
    homepage = https://github.com/prometheus/node_exporter;
    license = licenses.asl20;
    maintainers = with maintainers; [ benley fpletz ];
    platforms = platforms.unix;
  };
}
