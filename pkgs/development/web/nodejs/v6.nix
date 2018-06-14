{ stdenv, callPackage, lib, enableNpm ? true, ... }@args:

let
  buildNodejs = callPackage ./nodejs.nix args;
in
  buildNodejs {
    inherit enableNpm;
    version = "6.14.2";
    sha256 = "1lb2dpzamrag645l47gb33qqx8ppjimkb8gkczzwd5jymnr399dk";
    patches = lib.optionals stdenv.isDarwin [ ./no-xcode.patch ./no-xcodebuild.patch ];
  }
