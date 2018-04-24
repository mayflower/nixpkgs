{ stdenv, callPackage, lib, enableNpm ? true, ... }@args:

let
  buildNodejs = callPackage ./nodejs.nix args;
in
  buildNodejs {
    inherit enableNpm;
    version = "6.14.1";
    sha256 = "1hxyasy42ih9brgp37n9j85s5vwir3g32k5i3j0vx2kizy4xlphi";
    patches = lib.optionals stdenv.isDarwin [ ./no-xcode.patch ./no-xcodebuild.patch ];
  }
