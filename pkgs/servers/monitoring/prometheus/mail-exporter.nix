{ stdenv, buildGoPackage, fetchFromGitHub }:

buildGoPackage rec {
  name = "mailexporter-${version}";
  version = "2019-03-18";

  goPackagePath = "github.com/cherti/mailexporter";

  src = fetchFromGitHub {
    rev = "80084578942017dd239b41859713cc51e06adb9c";
    owner = "cherti";
    repo = "mailexporter";
    sha256 = "0akky98rn5pfs5xsbsy4bdn093vn790yij07xk3nqd0m5103kw9k";
  };

  postPatch = ''
    substituteInPlace mailexporter.go --replace \
      "prometheus.Handler" \
      "promhttp.Handler"
    sed -i mailexporter.go -e '/github.com\/prometheus\/client_golang\/prometheus/a \
      "github.com\/prometheus\/client_golang\/prometheus\/promhttp"'
  '';

  goDeps = ./mail-exporter_deps.nix;

  meta = with stdenv.lib; {
    description = "Export Prometheus-style metrics about mail server functionality";
    homepage = "https://github.com/cherti/mailexporter";
    license = licenses.gpl3;
    maintainers = with maintainers; [ willibutz ];
    platforms = platforms.linux;
  };
}
