{ pkgs? import <nixpkgs>{} 
}: 
pkgs.mkShell {
  name = "fdf";
  buildInputs = [
    (import ./fvim-basic.nix { inherit pkgs;})
    (import ./nvim.nix { inherit pkgs;})
  ];
}
 
