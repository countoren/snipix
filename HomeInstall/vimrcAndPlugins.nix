{ pkgs }:
 let
  my_plugins = import ./plugins.nix { inherit (pkgs) vimUtils fetchFromGitHub; };
