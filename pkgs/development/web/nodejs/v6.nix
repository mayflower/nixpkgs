{ stdenv, callPackage, lib, enableNpm ? true, ... }@args:

let
  buildNodejs = callPackage ./nodejs.nix args;
in
  buildNodejs {
    inherit enableNpm;
    version = "6.13.0";
    sha256 = "012dpfqxsrmd3xc4dmq0mik1kab4czf56s8wm2jvm7xjqvi6y5mp";
    patches = lib.optionals stdenv.isDarwin [ ./no-xcode.patch ./no-xcodebuild.patch ];
  }
