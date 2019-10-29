{ pkgs ? import <nixpkgs>{}
, additionalPlugins? []
, additionalCustPlugins? {}
, additionalVimrc? "" 
}:
with pkgs;
let 
  my_plugins = import ./plugins.nix { inherit vimUtils fetchFromGitHub; };
  vimrcFile = vimUtils.vimrcFile {
    customRC = (builtins.readFile ./vimrc) 
      + (if additionalVimrc == "" then "" else ''
        "Env Specific configuration:
        ''+ additionalVimrc);
      vam.knownPlugins = vimPlugins // my_plugins // additionalCustPlugins;
      vam.pluginDictionaries = [
        { names = [
          "vim-colorschemes"
          # "youcompleteme"
          "commentary"
          "supertab"  # needed to integrate UltiSnips and YouCompleteMe
          "ultisnips" # snippet engine
          "vim-snippets"  # snippet database
          "nerdtree"
          "ale"
          "ctrlp"
          "vim-addon-nix"
          "fugitive"
          "gitgutter"
          "vim-airline"
          "vim-airline-themes"
          "vim-javascript"
          "vim-nix"
          "vimproc"
          "wombat256-vim"
        ] ++ additionalPlugins; }
      ];
    };
  vimrcWithNixVimrc = writeText "vimrcWithNixVimrc" ''
    source ${vimrcFile}

    "VIMRC
    command! Vimrc silent :tabe $MYVIMRC

    "Command to set this nix vimrc to be sourced from home vimrc
    command! ReplaceHomeVimrcWithNixVimrc silent exec "!echo 'source ${vimrcFile}'> ~/.vimrc"
  '';
  
  in vimrcWithNixVimrc
