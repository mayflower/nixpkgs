{ stdenv, callPackage, lib, enableNpm ? true, ... }@args:

let
  buildNodejs = callPackage ./nodejs.nix args;
in
  buildNodejs {
    inherit enableNpm;
    version = "8.11.4";
    sha256 = "02d6a9sq81mbvap6h1ckwrang6wrxbkg0xxzn06wn2vbv7k7vkpv";
  }
