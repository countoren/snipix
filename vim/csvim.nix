{ pkgs ? import <nixpkgs>{}
, dotnet-sdk ? pkgs.dotnet-sdk_5
}:
    import ./linuxVim.nix 
    { 
      name = "csvim";
      paths = [ dotnet-sdk ];
      vimrcAndPlugins = import ./VimrcAndPlugins.nix
      {
        additionalPlugins = [
          "LanguageClient-neovim"
          "omnisharp-vim"
          "fzf-vim"
        ];
        additionalCustPlugins = {
          # https://github.com/ionide/Ionide-vim
          omnisharp-vim = pkgs.vimUtils.buildVimPluginFrom2Nix {
              name = "omnisharp-vim";
              src = pkgs.fetchFromGitHub {
                owner = "OmniSharp";
                repo = "omnisharp-vim";
                rev = "6302b8d";
                sha256 = "B/Z/Y6LWUliR/npH6hqWxx2fpUgnTTB4SPY5VJE9D9I=";
              };
            postInstall = '' '';
          };
        };
        additionalVimrc = '' 
         nnoremap <F5> :call LanguageClient_contextMenu()<CR>
         nnoremap <silent> gh :call LanguageClient_textDocument_hover()<CR>
         nnoremap <silent> gd :call LanguageClient_textDocument_definition()<CR>
         nnoremap <silent> gr :call LanguageClient_textDocument_references()<CR>
         nnoremap <silent> gs :call LanguageClient_textDocument_documentSymbol()<CR>
         nnoremap <silent> <F2> :call LanguageClient_textDocument_rename()<CR>
         nnoremap <silent> gf :call LanguageClient_textDocument_formatting()<CR>
        '';
      };
    }
