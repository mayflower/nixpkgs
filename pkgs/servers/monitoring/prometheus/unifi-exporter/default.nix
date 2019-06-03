{ stdenv, buildGoPackage, fetchFromGitHub }:

buildGoPackage rec {
  name = "unifi-exporter-${version}";
  version = "0.4.0+git2";
  rev = "5527cc436d27094c97eaeaf4c78dff8497d106bd";

  goPackagePath = "github.com/mayflower/unifi_exporter";

  src= fetchFromGitHub {
    inherit rev;
    owner = "mayflower";
    repo = "unifi_exporter";
    sha256 = "0fqwa176fms0a49wwd4896r4wn7g7p2awrlrhzx64ryrylnfbq4a";
  };

  meta = with stdenv.lib; {
    description = "Prometheus exporter that exposes metrics from a Ubiquiti UniFi Controller and UniFi devices";
    homepage = https://github.com/mdlayher/unifi_exporter;
    license = licenses.mit;
    maintainers = with maintainers; [ bachp ];
    platforms = platforms.unix;
  };
}
