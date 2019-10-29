{ pkgs ? import <nixpkgs> {}
, compiler ? "ghc865" 
}:
pkgs.stdenv.mkDerivation rec {
  name = "pslComplete";
  src = ../.;
  ghc = (import ./compiler.nix { version = compiler; }).ghcWithPackages (ps: with ps; [
            (import ../../dev/hs/lib.hs {inherit pkgs;} ).filemanip
        ]);
  buildInputs = [ ghc ];
  buildPhase = ''
    ghc ./test.hs 
  '';
  installPhase = ''
    cp ./test $out
  '';
} 
