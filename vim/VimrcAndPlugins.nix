{ pkgs ? import <nixpkgs>{}
, pkgsPath ? "~/Dropbox/nixpkgs"
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
          "tlib"
          "vim-addon-mw-utils"
          "commentary"
          "surround"
          "supertab"  # needed to integrate UltiSnips and YouCompleteMe
          "ultisnips-2019-07-08" # snippet engine
          # "vim-snippets"  # snippet database
          "dhall-vim"
          "vifm-vim"
          #"nerdtree"
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
          # "wombat256-vim"
        ] ++ additionalPlugins; }
      ];
    };
  vimrcWithNixVimrc = writeText "vimrcWithNixVimrc" ''
    let $MYVIMRC = '${pkgsPath}/vim/vimrc'
    let $VIMFolder = '${pkgsPath}/vim'
    let $MYPKGS = '${pkgsPath}'
    let $EDITOR = 'sp'

    " VIM Shell
    set shell=${pkgs.zsh}/bin/zsh

    " VIM Shell
    set shell=${pkgs.zsh}/bin/zsh

    source ${vimrcFile}


    "My Nix pkgs
    command! DPkgs silent :sp $MYPKGS
    "Vim folder
    command! DVim silent :sp $MYPKGS/vim
    "VIMRC
    command! FVimrc silent :sp $MYVIMRC

    "Command to set this nix vimrc to be sourced from home vimrc
    command! ReplaceHomeVimrcWithNixVimrc silent exec "!echo 'source ${vimrcFile}'> ~/.vimrc"
  '';
  
  in vimrcWithNixVimrc
