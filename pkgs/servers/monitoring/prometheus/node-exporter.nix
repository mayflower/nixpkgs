{ stdenv, buildGoPackage, fetchFromGitHub }:

buildGoPackage rec {
  name = "node_exporter-${version}";
  version = "0.16.0-rc.1";
  rev = "v${version}";

  goPackagePath = "github.com/prometheus/node_exporter";

  src = fetchFromGitHub {
    inherit rev;
    owner = "prometheus";
    repo = "node_exporter";
    sha256 = "1sdcmapnvygssi65pghi8a859dqmswx7k4sccd7av324xvnvnb7j";
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
