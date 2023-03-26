{ pkgs ? import <nixpkgs>{}
, pkgsPath ? toString  (import ../pkgsPath.nix)
, additionalPlugins? []
, additionalVimrc? "" 
}:
with pkgs;
let 
  my_plugins = builtins.attrValues (import ./plugins.nix { inherit vimUtils fetchFromGitHub; });
in 
{
  customRC = ''
    let $MYVIMRC = '${pkgsPath}/vim/vimrc'
    let $VIMFolder = '${pkgsPath}/vim'
    let $MYPKGS = '${pkgsPath}'
    let $EDITOR = 'sp'

    " VIM Shell
    set shell=${pkgs.zsh}/bin/zsh

    " VIM Shell
    set shell=${pkgs.zsh}/bin/zsh

    "Start terminal if not open in file
    autocmd VimEnter * if empty(bufname(''')) | cd $MYPKGS | endif
    autocmd VimEnter * if empty(bufname(''')) | exe "terminal" | endif
    ''
    + (builtins.readFile ./vimrc) + ''
    "My Nix pkgs
    command! DPkgs silent :sp $MYPKGS
    "Vim folder
    command! DVim silent :sp $MYPKGS/vim
    "VIMRC
    command! FVimrc silent :sp $MYVIMRC
    ''
    + (if additionalVimrc == "" then "" else ''
    "Env Specific configuration:
    ''+ additionalVimrc);

    packages.myPackages = with pkgs.vimPlugins;
    {
      start = [
      vim-eunuch
      vim-colorschemes
      # YouCompleteMe
      tlib
      vim-addon-mw-utils
      commentary
      surround
      supertab  # needed to integrate UltiSnips and YouCompleteMe
      vim-snippets  # snippet database
      dhall-vim
      vifm-vim
      ale
      ctrlp
      #vim-addon-nix
      fugitive
      gitgutter
      vim-lastplace

      vim-airline
      vim-airline-themes
      vim-javascript
      vim-nix
      vimproc
      ] 
      ++ my_plugins 
      ++ additionalPlugins; 
    };
}
