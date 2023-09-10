{ runCommand
, runtimeShell
, coreutils
, gnused
, gnugrep
, nix
, lib
, nixosTests
, installShellFiles
}:
let
  fallback = import ./../../../../nixos/modules/installer/tools/nix-fallback-paths.nix;
in
runCommand "nixos-rebuild" {
  src = ./nixos-rebuild.sh;
  nativeBuildInputs = [
    installShellFiles
  ];
  env = {
    inherit runtimeShell nix;
    nix_x86_64_linux = fallback.x86_64-linux;
    nix_i686_linux = fallback.i686-linux;
    nix_aarch64_linux = fallback.aarch64-linux;
    path = lib.makeBinPath [ coreutils gnused gnugrep ];
  };
  passthru.tests = {
    simple-installer = nixosTests.installer.simple;
    specialisations = nixosTests.nixos-rebuild-specialisations;
  };

  meta = {
    description = "Rebuild your NixOS configuration and switch to it, on local hosts and remote.";
    homepage = "https://github.com/NixOS/nixpkgs/tree/master/pkgs/os-specific/linux/nixos-rebuild";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.Profpatsch ];
    mainProgram = "nixos-rebuild";
  };
}
''
  mkdir -p $out/bin
  substituteAll $src $out/bin/$name
  chmod +x "$out"/bin/"$name"
  installManPage ${./nixos-rebuild.8}
''
