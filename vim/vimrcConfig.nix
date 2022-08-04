{ pkgs ? import <nixpkgs>{}
, pkgsPath ? "~/Dropbox/nixpkgs"
, additionalPlugins? []
, additionalCustPlugins? {}
, additionalVimrc? "" 
}:
with pkgs;
let 
  my_plugins = import ./plugins.nix { inherit vimUtils fetchFromGitHub; };
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
}
