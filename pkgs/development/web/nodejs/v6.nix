{ stdenv, callPackage, lib, openssl, enableNpm ? true }:

let
  buildNodejs = callPackage ./nodejs.nix { inherit openssl; };
in
  buildNodejs {
    inherit enableNpm;
    version = "6.14.4";
    sha256 = "03zc6jhid6jyi871zlcrkjqffmrpxh01z2xfsl3xp2vzg2czqjws";
  }
