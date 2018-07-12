{ pkgs }:
with pkgs;
let 
  my_plugins = import ./plugins.nix { inherit vimUtils fetchFromGitHub; };
in
  vimUtils.vimrcFile {
    customRC = builtins.readFile ./vimrc;
    vam.knownPlugins = vimPlugins // my_plugins;
    vam.pluginDictionaries = [
      { names = [
        "vim-colorschemes"
        "youcompleteme"
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
        "elm-vim"
        "vim-elixir"
        "vim-nix"
        "vimproc"
        "vimshell"
        "wombat256-vim"
      ]; }
    ];
  }
