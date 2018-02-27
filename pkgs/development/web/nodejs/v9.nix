{ stdenv, callPackage, lib, enableNpm ? true, ... }@args:

let
  buildNodejs = callPackage ./nodejs.nix args;
in
  buildNodejs {
    inherit enableNpm;
    version = "9.6.1";
    sha256 = "04hi7lwdizwqqbyi77f4z12gnsh673h92brmbssrmw5kjx6h4k5q";
    patches = lib.optionals stdenv.isDarwin [ ./no-xcode-v7.patch ];
  }
