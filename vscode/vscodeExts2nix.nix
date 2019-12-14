{ pkgs ? import <nixpkgs>{}
, vscode ? pkgs.vscode }:
with pkgs;
with rec {
  allExts = runCommand "c" { buildInputs = [ vscode python ]; } ''
    code --list-extensions --show-versions > $out
  '';
};
allExts
