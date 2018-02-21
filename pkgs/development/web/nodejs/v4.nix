{ stdenv, callPackage, lib, enableNpm ? true, ... }@args:

let
  buildNodejs = callPackage ./nodejs.nix args;
in
  buildNodejs {
    inherit enableNpm;
    version = "4.8.7";
    sha256 = "1y21wq092d3gmccm2zldbflbbbx7a71wi9l0bpkxvzmgws69liq3";
    patches = lib.optionals stdenv.isDarwin [ ./no-xcode.patch ];
  }
