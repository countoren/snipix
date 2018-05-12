{ pkgs }:

let
my_plugins = import ./plugins.nix { inherit (pkgs) vimUtils fetchFromGitHub; };

in with pkgs; vim_configurable.customize {
  name = "vim";
  vimrcConfig = {
    customRC = builtins.readFile ./vimrc;
    vam.knownPlugins = vimPlugins // my_plugins;
    vam.pluginDictionaries = [
      { names = [
        "vim-wombat"
        "ultisnips"
        "nerdtree"
        "ale"
        "ctrlp"
        "vim-addon-nix"
        "youcompleteme"
        "fugitive"
        "gitgutter"
        "vim-airline"
        "vim-airline-themes"
        "vim-javascript"
        "elm-vim"
        "vim-elixir"
      ]; }
    ];
  };
}

