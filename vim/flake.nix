{
  description = "My VIMS";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }: 
    # flake-utils.lib.eachDefaultSystem (system: {
    #   packages.hsvim = import ./hsvim.nix { pkgs = nixpkgs.legacyPackages.${system}; }; 
    #   defaultPackage = self.packages.${system}.hsvim;
    # })
    let darwinPkgs = { pkgs = nixpkgs.legacyPackages.x86_64-darwin; };
        # vimrcAndPlugin = 
    in
    {
      packages = {
        x86_64-darwin= {
          omvim = import ./macvim.nix darwinPkgs; 
          hsvim = import ./hsvim.nix darwinPkgs;
          fsvim = import ./fsvim.nix darwinPkgs;
        };
        x86_64-linux = {
        };
      };
      defaultPackage.x86_64-darwin = self.packages.x86_64-darwin.omvim;
    };
}
