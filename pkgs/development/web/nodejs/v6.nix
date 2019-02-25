{ stdenv, callPackage, lib, openssl, enableNpm ? true }:

let
  buildNodejs = callPackage ./nodejs.nix { inherit openssl; };
in
  buildNodejs {
    inherit enableNpm;
    version = "6.16.0";
    sha256 = "0ikmpn1kvp5q8andmiyhpr99zniqs86sdlfk31sj3k0wvalq420d";
  }
