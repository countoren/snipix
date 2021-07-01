{ pkgs ? import <nixpkgs> {}
, fetchurl ? pkgs.fetchurl
, unzip ? pkgs.unzip
, stdenv ? pkgs.stdenv
}:
stdenv.mkDerivation rec {
  name = "FsAutoComplete";
  version = "0.46.5";
  src = fetchurl { 
    url = "https://github.com/fsharp/${name}/releases/download/${version}/fsautocomplete.netcore.zip";
    sha256 = "1b1639f13yrx3ngs2v55bzsfkxvwa6pzldxpsirz87mx9vkj3jb4";
  };
  sourceRoot = ".";
  buildInputs = [ unzip ];
  buildPhase = ''
    chmod -R +r *
  '';
  installPhase = ''
    mkdir -p $out
    cp -r * $out/
  '';
}
