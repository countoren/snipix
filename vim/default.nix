{ pkgs }:

let
  my_plugins = import ./plugins.nix { inherit (pkgs) vimUtils fetchFromGitHub; };
  configurable_nix_path = <nixpkgs/pkgs/applications/editors/vim/configurable.nix>;
  my_vim_configurable = with pkgs; vimUtils.makeCustomizable (callPackage configurable_nix_path {
    inherit (darwin.apple_sdk.frameworks) CoreServices Cocoa Foundation CoreData;
    inherit (darwin) libobjc cf-private;

    features = "huge"; # one of  tiny, small, normal, big or huge
    lua = pkgs.lua5_1;
    gui = config.vim.gui or "auto";
    python = python3;

    # optional features by flags
    flags = [ "python" "X11" ];
  });


in with pkgs; my_vim_configurable.customize {
  name = "ovim";
  vimrcConfig = {
    customRC = builtins.readFile ./vimrc;
    vam.knownPlugins = vimPlugins // my_plugins;
    vam.pluginDictionaries = [
      { names = [
        "vim-colorschemes"
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
        "vim-nix"
        "vimproc"
        "vimshell"
      ]; }
    ];
  };
}

