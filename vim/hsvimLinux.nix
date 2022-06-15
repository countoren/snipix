{ pkgs ? import <nixpkgs>{}
, pkgsPath ? "~/Dropbox/nixpkgs" 
}:
let hsvim = 
    import ./linuxVim.nix 
    { 
      inherit pkgs;
      name = "hsvim";
      vimrcAndPlugins = import ./VimrcAndPlugins.nix
      {
        inherit pkgs pkgsPath;
        additionalPlugins = [
          # "LanguageClient-neovim"
          # "vim-lsp"
          "fzf-vim"
          "haskell-vim"
          "vim-hoogle"
          "coc-nvim"
          "asyncomplete-vim"

        ];
        additionalCustPlugins = {
          LanguageClient-neovim = import ./LanguageClient.nix { inherit pkgs; };
          # # https://github.com/ionide/Ionide-vim
          # ionide-vim = pkgs.vimUtils.buildVimPluginFrom2Nix {
          #     name = "ionide-vim";
          #     src = pkgs.fetchFromGitHub {
          #       owner = "ionide";
          #       repo = "Ionide-vim";
          #       rev = "f1d8c30";
          #       sha256 = "1njyngbq89jn1006y2ayvszwsphja40mqbhcnhjaf83k5wai2bs1";
          #     };
            # postInstall = ''
            #   ln -sf ${import ./fsac.nix { } } $target/fsac
            # '';
          # };
        };
        additionalVimrc = ''
        " COC config file 
        let g:coc_config_home = '${pkgs.writeTextDir "coc-settings.json" (builtins.toJSON {
              "diagnostic.maxWindowHeight" = 60;
              "diagnostic.virtualText" = true;
              "diagnostic.virtualTextCurrentLineOnly" = false;
              "codeLens.enable" = true;
              languageserver = {
                nix = {
                  command = "rnix-lsp";
                  filetypes = [ "nix" ];
                };
                haskell = {
                  command = "haskell-language-server";
                  args = [ "--lsp" "-d" "-l" "/tmp/LanguageServer.log" ];
                  rootPatterns = [ ".hie-bios" "cabal.project" ];
                  filetypes = [ "hs" "lhs" "haskell" ];
                  settings.languageServerHaskell.formattingProvider = "fourmolu";
                };
              };
            }
        )}'

        '';
      };
    };
    in 
    pkgs.buildEnv {
      name = "hsvim";
      paths = [ hsvim pkgs.haskell-language-server pkgs.nodejs pkgs.ghc pkgs.ghcid ];
    }
