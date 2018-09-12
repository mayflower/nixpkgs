{ stdenv, fetchFromGitLab, buildGoPackage, ruby, bundlerEnv }:

let
  rubyEnv = bundlerEnv {
    name = "gitaly-env";
    inherit ruby;
    gemdir = ./.;
  };
in buildGoPackage rec {
  version = "0.111.2";
  name = "gitaly-${version}";

  src = fetchFromGitLab {
    owner = "gitlab-org";
    repo = "gitaly";
    rev = "v${version}";
    sha256 = "1vv52gq7xzjwqs5bv6dx63gwdpfyrhw4aiqnlr3ba8yrif8v7p3x";
  };

  goPackagePath = "gitlab.com/gitlab-org/gitaly";

  passthru = {
    inherit rubyEnv;
  };

  buildInputs = [rubyEnv.wrappedRuby];

  postInstall = ''
    mkdir -p $ruby
    cp -rv $src/ruby/{bin,lib,vendor} $ruby
  '';

  outputs = [ "bin" "out" "ruby" ];

  meta = with stdenv.lib; {
    homepage = http://www.gitlab.com/;
    platforms = platforms.unix;
    maintainers = with maintainers; [ roblabla globin fpletz ];
    license = licenses.mit;
  };
}
