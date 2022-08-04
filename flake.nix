{
  description = "My system config";
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs;
    nixpkgsOld.url = "nixpkgs/nixos-21.11";
    home-manager.url = "github:nix-community/home-manager/release-21.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    #vims.url = "path:vim";
    #gpg.url = "/home/p1n3/nixpkgs/gpg";
    #network.url = "path:network";
  };

  outputs = { nixpkgs, nixpkgsOld, home-manager,... }: 
    let 
       system = "x86_64-linux";
       pkgs = import nixpkgs {
          inherit system;
          config = import ./config.nix;
       };
       pkgsOld = import nixpkgsOld {
          inherit system;
          config = import ./config.nix;
       };
       lib = nixpkgs.lib;
    in {
       homeManagerConfigurations = {
          p1n3 = home-manager.lib.homeManagerConfiguration {
            inherit system;

            username = "p1n3";
            homeDirectory = "/home/p1n3";
            configuration = {
              imports = [ ./network/nixos.nix ];
                home.packages = [ pkgs.wl-clipboard ];
                programs.password-store = {
                  enable = true;
                  settings.PASSWORD_STORE_DIR = "/run/media/p1n3/Untitled\ 2/password-store";
                  settings.PASSWORD_STORE_KEY = "countoren@gmail.com";
                };

                programs.git = {
                  enable = true;
                  userName = "countoren@protonmail.com";
                };
                
                home.file.".bashrc".source = ./dotfiles/bashrc;
                home.file.".zshrc".text  = import ./dotfiles/zshrc_nixos { inherit pkgs; };
            }; #// ( import ./network/nixos.nix { inherit pkgs; });
            
          };	
       };
       nixosConfigurations = {
         p1n3 = lib.nixosSystem {
           inherit system;
           modules = [ 
                (import ./nixos/configuration.nix pkgs)
                {
                  config = {
                    environment.systemPackages = [ 
                    #ONIX - nixos p1n3
                    #ONIX END
                    #(import ./vim/linuxVim.nix { pkgs = pkgsOld; })
                    (import ./vim/neovide.nix { inherit pkgs; })
                    (import ./git { inherit pkgs; })
                    (import ./nixUtils { inherit pkgs; })
                    ];
                 };
                }
              ];
         };
       };
    };

  }
