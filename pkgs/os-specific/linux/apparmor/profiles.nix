{ stdenv, pkgs }:

{
  ping = import ./profiles/ping.nix { inherit stdenv pkgs; inherit (pkgs) iputils nettle libcap libcap_ng libidn; };
}
