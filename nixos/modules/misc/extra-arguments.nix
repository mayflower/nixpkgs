{ config, pkgs, ... }:

{
  _module.args = {
    utils = import ../../lib/utils.nix config pkgs;
  };
}
