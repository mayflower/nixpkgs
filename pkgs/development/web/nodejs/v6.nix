{ stdenv, callPackage, lib, openssl, enableNpm ? true }:

let
  buildNodejs = callPackage ./nodejs.nix { inherit openssl; };
in
  buildNodejs {
    inherit enableNpm;
    version = "6.15.1";
    sha256 = "1hi9h54ni7m1lmhfqvwxdny969j31mixxlxsiyl00l2bj25fbgf3";
  }
