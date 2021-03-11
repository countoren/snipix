{ pkgs ? import <nixpkgs>{} }:
pkgs.stdenv.mkDerivation {
  name = "obs-stream-darwin";
  src = pkgs.fetchurl { 
    url = "https://github.com/obsproject/obs-studio/releases/download/26.1.2/obs-mac-26.1.2.dmg"; 
    sha256="0p885ynyczi6lrm59j6kccmcjbv3wpb49i1yg86x4prwyajm5f22"; 
  };
  buildInputs = [ pkgs.undmg ];
  buildCommand = ''
  undmg "$src"

        mkdir -p $out/Applications
        cp -rfv OBS.app $out/Applications
  '';
}
