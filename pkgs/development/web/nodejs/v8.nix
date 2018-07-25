{ stdenv, callPackage, lib, enableNpm ? true, ... }@args:

let
  buildNodejs = callPackage ./nodejs.nix args;
in
  buildNodejs {
    inherit enableNpm;
    version = "8.11.3";
    sha256 = "1q3fc791ng1sgk0i5qnxpxri7235nkjm50zx1z34c759vhgpaz2p";
    patches = lib.optionals stdenv.isDarwin [ ./no-xcode-v7.patch ./no-xcodebuild.patch ];
  }
