{ lib, buildGoModule, fetchurl, fetchFromGitHub, nixosTests }:

buildGoModule rec {
  pname = "grafana";
  version = "7.1.3";

  excludedPackages = [ "release_publisher" ];

  src = fetchFromGitHub {
    rev = "v${version}";
    owner = "grafana";
    repo = "grafana";
    sha256 = "1acvvqsgwfrkqmbgzdxfa8shwmx7c91agaqv3gsfgpqkqwp3pnmh";
  };

  srcStatic = fetchurl {
    url = "https://dl.grafana.com/oss/release/grafana-${version}.linux-amd64.tar.gz";
    sha256 = "0c72xmazr3rgiccrqcy02w30159vsq9d78dkqf5c2yjqn8zzwf98";
  };

  modSha256 = "0qw41vx6q3cr8nrfv5rb7j8q3k7kfds93s6q2mjxc1l4h3mkwdvl";

  postPatch = ''
    substituteInPlace pkg/cmd/grafana-server/main.go \
      --replace 'var version = "5.0.0"'  'var version = "${version}"'
  '';

  postInstall = ''
    tar -xvf $srcStatic
    mkdir -p $out/share/grafana
    mv grafana-*/{public,conf,tools} $out/share/grafana/
  '';

  passthru.tests = { inherit (nixosTests) grafana; };

  meta = with lib; {
    description = "Gorgeous metric viz, dashboards & editors for Graphite, InfluxDB & OpenTSDB";
    license = licenses.asl20;
    homepage = "https://grafana.com";
    maintainers = with maintainers; [ offline fpletz willibutz globin ma27 Frostman ];
    platforms = platforms.linux;
  };
}
