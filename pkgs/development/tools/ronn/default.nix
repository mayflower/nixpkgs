{ stdenv, lib, bundlerEnv, bundlerUpdateScript, makeWrapper, groff, callPackage }:
let
  ronn-gems = bundlerEnv {
    name = "ronn-gems";
    gemdir = ./.;
  };
in
stdenv.mkDerivation {
  pname = "ronn";
  version = ronn-gems.gems.ronn-ng.version;

  dontUnpack = true;

  nativeBuildInputs = [
    makeWrapper
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    makeWrapper ${ronn-gems}/bin/ronn $out/bin/ronn \
      --set PATH ${groff}/bin

    runHook postInstall
  '';

  passthru.updateScript = bundlerUpdateScript "ronn";

  passthru.tests.reproducible-html-manpage = callPackage ./test-reproducible-html.nix { };

  meta = with lib; {
    description = "markdown-based tool for building manpages";
    homepage = "https://github.com/apjanke/ronn-ng";
    license = licenses.mit;
    maintainers = with maintainers; [ zimbatm nicknovitski ];
    platforms = ronn-gems.ruby.meta.platforms;
  };
}
