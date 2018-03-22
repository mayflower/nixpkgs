{ stdenv, buildGoPackage, fetchFromGitHub }:

buildGoPackage rec {
  name = "node_exporter-${version}";
  version = "0.16.0-rc.0";
  rev = "002c1ca02917406cbecc457162e2bdb1f29c2f49";

  goPackagePath = "github.com/prometheus/node_exporter";

  src = fetchFromGitHub {
    inherit rev;
    owner = "mayflower";
    repo = "node_exporter";
    sha256 = "1j4h75s0lpjgl06lzfhwmxdf112av2acn2q2lrww6hp33fz5gb69";
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
