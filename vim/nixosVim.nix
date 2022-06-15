{ pkgs ? import <nixpkgs> {} 
, vimrcAndPlugins ? import ./VimrcAndPlugins.nix { inherit pkgs; }
, name ? "vim"
, vim ? pkgs.vimHugeX
}:
/*

pkgs.vimHugeX
.customize {
   name = "vim";
   vimrcConfig.customRC = builtins.readFile vimrcAndPlugins;
   wrapGui = true; 
}
pkgs.vimUtils.vimWithRC {
      vimExecutable = "${vim}/bin/vim";
      gvimExecutable = "${vim}/bin/gvim";
      name = "vim";
      wrapManual = true;
      wrapGui = true; 
      vimExecutableName = "vim";
      gvimExecutableName = "gvim";
      vimrcFile = vimrcAndPlugins;
      vimManPages = pkgs.buildEnv {
        name = "vim-doc";
        paths = [ vim ];
        pathsToLink = [ "/share/man" ];
      };
}
*/
pkgs.symlinkJoin {
  inherit name;
  paths = [
    (vim.override { python = pkgs.python3; }) 
    #this function will trigger vimrc sp function in order to split window when used terminal from vim
    (pkgs.writeShellScriptBin "sp" ''
      printf '\033]51;["call", "Tapi_sp", ["%s"]]\007' `realpath $1`
    '')
    #this function will set working dir to terminal's pwd used terminal from vim
    (pkgs.writeShellScriptBin "cdv" ''
      printf '\033]51;["call", "Tapi_lcd", ["%s"]]\007' "$(pwd)"
    '')
  ];
  buildInputs = [ pkgs.makeWrapper ];
  postBuild = ''
    ln -sf ${vimrcAndPlugins} $out/share/vim/vimrc
    wrapProgram $out/bin/vim \
      --add-flags "-u ${vimrcAndPlugins}"

    wrapProgram $out/bin/gvim \
      --add-flags "-u ${vimrcAndPlugins}"
  '';
}
  
