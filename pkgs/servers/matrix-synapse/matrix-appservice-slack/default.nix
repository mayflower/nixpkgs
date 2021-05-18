{ mkYarnPackage, stdenv, fetchFromGitHub, lib, nodejs, makeWrapper }:

mkYarnPackage rec {
  pname = "matrix-appservice-slack";
  version = "1.8.0";
  nativeBuildInputs = [ makeWrapper ];

  yarnLock = ./yarn.lock;
  yarnNix = ./yarn.nix;
  packageJSON = ./package.json;

  src = fetchFromGitHub {
    owner = "matrix-org";
    repo = "matrix-appservice-slack";
    rev = version;
    sha256 = "sha256-FA6SMivMnloeZmnUhGx6N+ZLDTZFO3y17xJYclkp5w0=";
  };

  buildPhase = ''
    yarn --offline build
  '';

  postInstall = ''
    makeWrapper '${nodejs}/bin/node' "$out/bin/matrix-appservice-slack" \
    --add-flags "$out/libexec/matrix-appservice-slack/deps/matrix-appservice-slack/lib/app.js"
  '';

  meta = with lib; {
    description = "A Matrix <--> Slack bridge";
    maintainers = with maintainers; [ kampka ];
    license = licenses.asl20;
  };
}
