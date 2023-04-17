
{ pkgs ? (builtins.getFlake (toString ../.)).inputs.nixpkgs.legacyPackages.${builtins.currentSystem}
, lib ? pkgs.lib
, gitDrv ? pkgs.git
, fzf ? "${pkgs.fzf}/bin/fzf"
, pkgsPath ? toString (import ../pkgsPath.nix)
, additionalVimrc? ""
, additionalPlugins ? [] 
, vimrcConfig ? import ./vimrcConfig.nix { inherit pkgs pkgsPath;
  additionalVimrc = additionalVimrc + ''
      " nvim specific configs
      autocmd TermOpen * startinsert
      luafile ${./config.lua}

      let g:terminal_color_0 = "#232627"
      let g:terminal_color_1 = "#ed1515"
      let g:terminal_color_2 = "#11d116"
      let g:terminal_color_3 = "#f67400"
      let g:terminal_color_4 = "#1d99f3"
      let g:terminal_color_5 = "#9b59b6"
      let g:terminal_color_6 = "#1abc9c"
      let g:terminal_color_7 = "#fcfcfc"
      let g:terminal_color_8 = "#7f8c8d"
      let g:terminal_color_9 = "#c0392b"
      let g:terminal_color_10 = "#1cdc9a"
      let g:terminal_color_11 = "#fdbc4b"
      let g:terminal_color_12 = "#3daee9"
      let g:terminal_color_13 = "#8e44ad"
      let g:terminal_color_14 = "#16a085"
      let g:terminal_color_15 = "#ffffff"

      '';  
      additionalPlugins = with pkgs.vimPlugins; [
        (nvim-treesitter.withPlugins (p: [ 
          p.nix p.jq
          p.c p.cpp p.javascript p.bash p.bibtex p.c_sharp p.css p.dockerfile 
          p.git_rebase p.gitattributes p.gitignore p.html p.latex p.lua p.markdown 
          p.markdown_inline p.rust p.sql p.typescript p.vim p.yaml p.go 
        ]))

      #does not work for now it seems ts-rainbow returns nil in config.lua
      # local rainbow = require 'ts-rainbow'
      #nvim-ts-rainbow2
    ] ++ additionalPlugins;
  }
, prefix? "nvim"
}:
let 
  nvim = pkgs.neovim.override {
    configure = vimrcConfig;
  };
  git = gitDrv+"/bin/git";
  nvim-exe = nvim+"/bin/nvim";
  commands = 
  lib.attrValues (lib.fix (self: lib.mapAttrs pkgs.writeShellScript (
  {
    git-project-path = ''${git} rev-parse --show-toplevel'';
    maybe-realpath = ''
      _p="$@"
      [ -z "$_p" ] && echo $_p || realpath $_p
    '';
    nvim-server = ''
      ${self.nvim-clean-server-files}
      ${nvim-exe} --listen $(${self.nvim-server-file}) "$@" 
    '';
    nvim-client = ''${nvim-exe} --server "$(${self.nvim-get-server-file})" --remote $(${self.maybe-realpath} "$@") '';
    nvim-clean-server-files = ''
      for server in $(ls $HOME/.cache/nvim/*.pipe); do
        echo $server | ${self.nvim-client-expr-with-server} "echo" 2> /dev/null || rm -f $server
      done
    '';

    nvim-client-expr = ''${nvim-exe} --server $(${self.nvim-get-server-file}) --remote-expr "execute(\"$@\")" '';
    nvim-client-expr-with-server = ''${nvim-exe} --server $(cat -) --remote-expr "execute(\"$@\")" '';
    # $NVIM - is nvim env variable that load with the specific nvim .pipe(address) path/url
    nvim-client-send = ''${nvim-exe} --server $NVIM --remote-send "<C-\><C-N>:$1 $(${self.maybe-realpath} "''\${@:2}")<CR>" '';
    sp = '' ${self.nvim-client-send} sp "$@" '';
    ed = '' ${self.nvim-client-send} edit "$@" '';
    vsp = '' ${self.nvim-client-send} vsp "$@" '';
    cdv = '' ${self.nvim-client-send} cd $(pwd) '';
    nvim-server-file = ''echo $HOME"/.cache/nvim/$(date +"%d_%m_%YT%H_%M_%S").pipe" '';

    nvim-get-all-servers-with-location = ''
      for server in $(ls $HOME"/.cache/nvim" | grep ".pipe$"); do
        echo "$server - "$(${self.nvim-client-expr} "pwd")
      done
    '';
    nvim-get-server-file = ''
      ls $HOME/.cache/nvim/*.pipe | ${fzf} --tac -0 -1
    '';

    nvim-open = ''
      _params="$@"
      if ls $HOME/.cache/*.pipe >/dev/null 2>&1; then
        ${self.nvim-client} $_params
      else
        ${self.nvim-server} $_params
      fi
    '';

    nvim = '' ${self.nvim-server} "$@" '';
    
  }
  )));
in
pkgs.runCommand prefix {
  name = prefix;
  version = "1.0.0";
  }
  ''
    mkdir -p $out/bin
    ${lib.concatMapStringsSep " " (c: ''
      ln -nfs ${c} $out/bin/${c.name}
    '') commands}
  ''
