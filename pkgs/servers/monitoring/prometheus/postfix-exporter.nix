{ stdenv, buildGoPackage, fetchFromGitHub, systemd, makeWrapper }:

buildGoPackage rec {
  name = "postfix_exporter-${version}";
  version = "0.1.0";

  goPackagePath = "github.com/kumina/postfix_exporter";

  src = fetchFromGitHub {
    owner = "kumina";
    repo = "postfix_exporter";
    rev = version;
    sha256 = "1hv8d9ik49rnxlc9mlfx9bqq8rjc4zk3d3jk71kl46wajkjlsy8i";
  };

  patches = [ ./postfix-exporter_systemd-journal.patch ];

  buildInputs = [ systemd makeWrapper ];

  goDeps = ./postfix-exporter-deps.nix;

  postInstall = ''
    wrapProgram $bin/bin/postfix_exporter \
      --prefix LD_LIBRARY_PATH : "${systemd.lib}/lib"
  '';

  meta = with stdenv.lib; {
    inherit (src.meta) homepage;
    description = "A Prometheus exporter for Postfix";
    license = licenses.asl20;
    maintainers = with maintainers; [ willibutz ];
  };
}
