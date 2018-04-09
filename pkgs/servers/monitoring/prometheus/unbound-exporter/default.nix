{ stdenv, lib, go, buildGoPackage, fetchFromGitHub, prometheus }:

buildGoPackage rec {
  name = "prometheus-unbound-exporter-${version}";
  version = "0.1+git20171204";
  rev = "4f36729f553665a4268b5c265448977276a95096";

  goPackagePath = "github.com/kumina/unbound_exporter";

  goDeps = ./deps.nix;

  src = fetchFromGitHub {
    inherit rev;
    owner = "kumina";
    repo = "unbound_exporter";
    sha256 = "0py4h0185f13v1rz8wr8ha35cw5c4hfdjsk7x82a9vqqpqpby63s";
  };

  meta = with stdenv.lib; {
    inherit (src.meta) homepage;
    description = "Simple Prometheus metrics exporter for the Unbound DNS resolver.";
    license = licenses.asl20;
    maintainers = with maintainers; [ fpletz ];
    platforms = platforms.unix;
  };
}
