{ stdenv, go, buildGoPackage, fetchFromGitHub }:

buildGoPackage rec {
  name = "alertmanager-${version}";
  version = "0.11.0";
  rev = "v${version}";

  goPackagePath = "github.com/prometheus/alertmanager";

  src = fetchFromGitHub {
    inherit rev;
    owner = "prometheus";
    repo = "alertmanager";
    sha256 = "1r9ykn9xj9xziqi7rqfx9yff7k3jribj92i6n3qpqcxkask1rl2a";
  };

  # Tests exist, but seem to clash with the firewall.
  doCheck = false;

  buildFlagsArray = let t = "${goPackagePath}/vendor/github.com/prometheus/common/version"; in ''
    -ldflags=
       -X ${t}.Version=${version}
       -X ${t}.Revision=${rev}
       -X ${t}.Branch=unknown
       -X ${t}.BuildUser=nix@nixpkgs
       -X ${t}.BuildDate=unknown
       -X ${t}.GoVersion=${stdenv.lib.getVersion go}
  '';

  postBuild = ''
    $NIX_BUILD_TOP/go/bin/artifacts
  '';

  postInstall = ''
    rm $bin/bin/artifacts
    mkdir -p $bin/share/man/man1 $bin/etc/bash_completion.d
    cp -v amtool*.1 $bin/share/man/man1
    cp -v amtool_completion.sh $bin/etc/bash_completion.d
  '';

  meta = with stdenv.lib; {
    description = "Alert dispatcher for the Prometheus monitoring system";
    homepage = https://github.com/prometheus/alertmanager;
    license = licenses.asl20;
    maintainers = with maintainers; [ benley fpletz ];
    platforms = platforms.unix;
  };
}
