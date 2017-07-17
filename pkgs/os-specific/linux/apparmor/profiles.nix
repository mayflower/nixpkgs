{ stdenv, pkgs, builtins }:

let
  storeDir = builtins.storeDir;
in {
  ping = import ./profiles/ping.nix { inherit stdenv pkgs storeDir; inherit (pkgs) iputils nettle libcap libcap_ng libidn; };
}
