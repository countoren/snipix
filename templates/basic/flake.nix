{
  inputs.flake-utils.url = github:numtide/flake-utils;

  outputs = { self, nixpkgs, flake-utils }:
  #flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
  flake-utils.lib.eachDefaultSystem (system:
  let pkgs = nixpkgs.legacyPackages.${system};
  in rec {
    templates.basic = {
      description = "basic-flake"; 
      path = ./dist/nix/templates/simple-neovim; 
    };
    templates.default = templates.basic;
  });
}
