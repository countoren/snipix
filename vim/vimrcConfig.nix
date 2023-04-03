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

    "sneak mapping
    nnoremap <leader>, <Plug>Sneak_,
    nnoremap , <Plug>Sneak_;

    ''
    + (if additionalVimrc == "" then "" else ''
    "Env Specific configuration:
    ''+ additionalVimrc);

    

    packages.myPackages = with pkgs.vimPlugins;
    {
      start = [

      # Style
      vim-colorschemes
      vim-airline
      vim-airline-themes

      # Errors showing 
      ale

      # Global Search
      ctrlp

      # Editing
      surround
      commentary
      supertab  # needed to integrate UltiSnips and YouCompleteMe
      vim-snippets  # snippet database
      vim-lastplace
      indentLine
      # tlib not sure why i added it to be removed if there is no problem
      #LSP 
      vim-lsp


      # Nix 
      vim-nix

      # Shell commands helper and file managers
      vim-eunuch
      vifm-vim

      #Motions
      vim-sneak

      # Git
      fugitive
      gitgutter

      # Misc
      # vimproc not sure if it is needed
      # vim-addon-mw-utils





      ] 
      ++ my_plugins 
      ++ additionalPlugins; 
    };
}
