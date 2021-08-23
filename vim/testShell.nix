{ pkgs ? import <nixpkgs>{}
}:
pkgs.mkShell {
  name = "test";
  buildInputs = [
    (import ./cppVim.nix { inherit pkgs; } )
    pkgs.nodejs
    pkgs.ccls
  ];
}
