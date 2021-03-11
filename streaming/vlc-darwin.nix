{ pkgs ? import <nixpkgs>{} }:
let drv = pkgs.stdenv.mkDerivation {
  name = "vlc-darwin";
  src = pkgs.fetchurl { 
    url = "https://ftp.osuosl.org/pub/videolan/vlc/3.0.12/macosx/vlc-3.0.12-intel64.dmg"; 
    sha256="1lg5kd2b55072lnpq4k1f74cixqp2i6g63b883l4hx0dxrw5m2wv"; 
  };
  buildInputs = [ pkgs.undmg ];
  buildCommand = ''
    undmg "$src"
    mkdir -p $out/Applications
    cp -rfv VLC.app $out/Applications
  '';
};
in 
  pkgs.buildEnv {
    name = "VLC";
    paths = [
      drv
      (pkgs.writeShellScriptBin "vlc" ''
          open ${drv}/Applications/*.app
      '')
    ];
  }
