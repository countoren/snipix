{ pkgs }:
{
  lib = import ./lib.nix { inherit pkgs; } ;
  init = import ./init.nix { inherit pkgs; };
}
