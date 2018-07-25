{ stdenv, callPackage, lib, enableNpm ? true, ... }@args:

let
  buildNodejs = callPackage ./nodejs.nix args;
in
  buildNodejs {
    inherit enableNpm;
    version = "6.14.3";
    sha256 = "1jbrfk875aimm65wni059rrydmhp4z0hrxskq3ci6jvykxr8gwg3";
    patches = lib.optionals stdenv.isDarwin [ ./no-xcode.patch ./no-xcodebuild.patch ];
  }
