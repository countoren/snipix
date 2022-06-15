{
  description = "My VIMS";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixpkgs.url = "nixpkgs/nixos-21.11";

  outputs = { self, nixpkgs, flake-utils }: 
    let darwinPkgs = { pkgs = nixpkgs.legacyPackages.x86_64-darwin; };
        linuxPkgs = nixpkgs.legacyPackages.x86_64-linux;
    in
    {
      packages = {
        x86_64-darwin= {
          omvim = import ./macvim.nix darwinPkgs; 
          hsvim = import ./hsvim.nix darwinPkgs;
          fsvim = import ./fsvim.nix darwinPkgs;
        };
        x86_64-linux = {
          #linux vim no GUI
          lvim = import ./linuxVim.nix { pkgs = linuxPkgs; };
        };
      };
      nixosModule = {config, ...} : { 
         config = { environment.systemPackages = [ self.packages.x86_64-linux.lvim ]; };
      };
      defaultPackage.x86_64-darwin = self.packages.x86_64-darwin.omvim;
      defaultPackage.x86_64-linux = self.packages.x86_64-linux.lvim;
    };
}
