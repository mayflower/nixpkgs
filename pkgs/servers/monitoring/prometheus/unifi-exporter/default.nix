{ stdenv, buildGoPackage, fetchFromGitHub }:

buildGoPackage rec {
  name = "unifi-exporter-${version}";
  version = "0.4.0+git2";
  rev = "85455df7c491b44c8589b95b6b9401881762b9e2";

  goPackagePath = "github.com/mdlayher/unifi_exporter";

  src= fetchFromGitHub {
    inherit rev;
    owner = "mdlayher";
    repo = "unifi_exporter";
    sha256 = "1cs6zris9jx9w4h9qa50rrwcmjw5ncs66xjaq13dkg69yyrn2a5k";
  };

  meta = with stdenv.lib; {
    description = "Prometheus exporter that exposes metrics from a Ubiquiti UniFi Controller and UniFi devices";
    homepage = https://github.com/mdlayher/unifi_exporter;
    license = licenses.mit;
    maintainers = with maintainers; [ bachp ];
    platforms = platforms.unix;
  };
}
