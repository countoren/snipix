{ pkgs ? import <nixpkgs>{} }:
{ name ? "DEFAULT"
, url 
, sha256 ? "1lg5k33333333333333333333333333333333333333333333333" 
}:
let drv = pkgs.stdenv.mkDerivation {
  inherit name;
  src = pkgs.fetchurl { inherit url sha256;};
  buildInputs = [ pkgs.undmg ];
  buildCommand = ''
    echo 'undmg on '"$src"
    undmg "$src"
    mkdir -p $out/Applications
    echo 'app name is:'
    ls 
    cp -rfv ${name}.app $out/Applications
  '';
};
in 
  pkgs.buildEnv {
    inherit name;
    paths = [
      drv
      (pkgs.writeShellScriptBin (pkgs.lib.toLower name) ''
          open ${drv}/Applications/*.app
      '')
    ];
  }
