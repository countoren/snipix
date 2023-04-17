{
  description = "My system config";
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs;
    nixpkgsOld.url = "nixpkgs/nixos-21.11";
    nixpkgsWork.url = github:NixOS/nixpkgs/9ef6e7727f4c31507627815d4f8679c5841efb00;
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    #vims.url = "path:vim";
    #gpg.url = "/home/p1n3/nixpkgs/gpg";
    #network.url = "path:network";
  };

  outputs = { nixpkgs, nixpkgsOld, nixpkgsWork, home-manager,... }:
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
       pkgsWork = import nixpkgsWork {
          inherit system;
       };
       lib = nixpkgs.lib;
    in {
       homeManagerConfigurations = {
          orozen = home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            modules = [
              {
                home.username = "orozen";
                home.homeDirectory = "/home/orozen";
                home.stateVersion = "22.11";

                programs.git = {
                  enable = true;
                  userName = "Oren Rozen";
                  userEmail = "orozen@carlsonsw.com";
                };
                home.file.".bashrc".source = ./dotfiles/bashrc;
                home.file.".zshrc".text  = import ./dotfiles/zshrc_nixos { inherit pkgs; };

              }
            ];
          };

          p1n3 = home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            modules = [
            ./network/nixos.nix
            {
              home.username = "p1n3";
              home.homeDirectory = "/home/p1n3";
              home.stateVersion = "22.11";
              home.packages = [ pkgs.wl-clipboard ];
              home.file.".bashrc".source = ./dotfiles/bashrc;
              home.file.".zshrc".text  = import ./dotfiles/zshrc_nixos { inherit pkgs; };

              programs.password-store = {
                enable = true;
                settings.PASSWORD_STORE_DIR = "/run/media/p1n3/Untitled\
                2/password-store";
                settings.PASSWORD_STORE_KEY = "countoren@gmail.com";
              };

              programs.git = {
                enable = true;
                userEmail = "countoren@protonmail.com";
              };

            } #// ( import ./network/nixos.nix { inherit pkgs; });
          ];
         };
       };

       nixosConfigurations = {
         work-vb = nixpkgsWork.lib.nixosSystem {
           inherit system;
           modules = [
            ./nixos/work-vb/configuration.nix 
            ./nixos/common.nix
            {
              config = {
                environment.systemPackages = with pkgs; [
                  ( pkgs.writeShellScriptBin "install-home" ''
                      nix run .#homeManagerConfigurations.orozen.activationPackage
                  '')
                  (import ./work { inherit pkgs;})
                  (import ./vim/gnvim.nix { inherit pkgs;
                        pkgsPath = "/home/orozen/nixpkgs";
                  })
                  (import ./git { inherit pkgs; })
                  (import ./nixUtils { inherit pkgs; })
                  (import ./searchUtils { inherit pkgs; })
                ];
              };
            }
           ];
         };
         p1n3 = lib.nixosSystem {
           inherit system;
           modules = [
                (import ./nixos/configuration.nix pkgs)
                {
                  config = {
                    environment.systemPackages = with pkgs; [
                    ( pkgs.writeShellScriptBin "install-home" ''
                      nix run .#homeManagerConfigurations.p1n3.activationPackage
                    '')
                    #ONIX - nixos p1n3
                    #ONIX END
                    wifite2
                    iw
                    macchanger
                    john

                    #PDF tools
                    zathura
                    pdfsandwich
                    (import ./vim/neovide.nix { inherit pkgs;
                      pkgsPath = toString (import ./pkgsPath.nix);
                    })
                    (import ./git { inherit pkgs; })
                    (import ./nixUtils { inherit pkgs; })
                    (import ./searchUtils { inherit pkgs; })
                    ];
                 };
                }
              ];
         };
       };
    };

  }
