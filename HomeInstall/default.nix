{ pkgs ? import <nixpkgs> {} }:
with pkgs;

let
  inherit stdenv fetchurl perl;
  version = "1.0.0";
in
stdenv.mkDerivation rec {
  name = "homeInstall";
  phases = [ "installPhase" ];
  src = ./.;
  installPhase = ''
    install -dm 755 $out/bin
    substitute $src/homeInstallSymLinks $out/bin/homeInstallSymLinks
    chmod -x $out/bin/homeInstallSymLinks
  '';
}
