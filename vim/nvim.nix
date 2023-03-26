{ pkgs ? (builtins.getFlake (toString ../.)).inputs.nixpkgs.legacyPackages.${builtins.currentSystem}
, lib ? pkgs.lib
, gitDrv ? pkgs.git
, fzf ? "${pkgs.fzf}/bin/fzf"
, pkgsPath ? toString (import ../pkgsPath.nix)
, additionalVimrc? ""
, vimrcConfig ? import ./vimrcConfig.nix { inherit pkgs pkgsPath;
    additionalVimrc = additionalVimrc + ''
      " nvim specific configs
      autocmd TermOpen * startinsert
    '';  
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
    nvim-client-send = ''${nvim-exe} --server $(${self.nvim-get-server-file}) --remote-send "<C-\><C-N>:$1 $(${self.maybe-realpath} "''\${@:2}")<CR>" '';
    sp = '' ${self.nvim-client-send} sp "$@" '';
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
