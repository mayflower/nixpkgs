{ qtSubmodule, qtbase, qtdeclarative, assimp }:

qtSubmodule {
  name = "qt3d";
  qtInputs = [ qtbase qtdeclarative ];
  outputs = [ "out" "dev" "bin" ];
  postInstall = ''
    moveToOutput "$qtQmlPrefix" "$bin"
  '';
}
