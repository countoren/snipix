{
  description = "My Git";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-21.11";
  };

  outputs = { nixpkgs, ... }: 
  let 
     system = "x86_64-linux";
     pkgs = import nixpkgs { inherit system; };
     lib = nixpkgs.lib;
  in rec {
    defaultTemplate = {
      path = ./.;
      description = "Git example of CLI tools with recursive strcuture";
    };


    defaultPackage.${system} = import ./default.nix { inherit pkgs; };
    defaultApp.${system} = defaultPackage.${system};
  };
}
