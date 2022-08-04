{ pkgs ? import <nixpkgs> {} 
, additionalVimrc?  ''
set clipboard=unnamed
set clipboard=unnamedplus
set columns=200
set lines=100
set guifont=Inconsolata\ 14
tmap <C-v> <C-W>"+
let $EDITOR = 'sp'
''
, vimrcAndPlugins ? import ./VimrcAndPlugins.nix { inherit pkgs additionalVimrc; }
, name ? "vim"
, vim ? pkgs.vimHugeX
, paths ? []
#this function will trigger vimrc sp function in order to split window when used terminal from vim
, sp ? (pkgs.writeShellScriptBin "sp" ''
      printf '\033]51;["call", "Tapi_sp", ["%s"]]\007' `realpath $1`
'')
#this function will set working dir to terminal's pwd used terminal from vim
, cdv ? (pkgs.writeShellScriptBin "cdv" ''
      printf '\033]51;["call", "Tapi_lcd", ["%s"]]\007' "$(pwd)"
'')
}:
pkgs.symlinkJoin {
  inherit name;
  paths = [
    vim
    sp 
    cdv
  ] ++ paths;
  buildInputs = [ pkgs.makeWrapper ];
  postBuild = ''
    ln -sf ${vimrcAndPlugins} $out/share/vim/vimrc
    wrapProgram $out/bin/vim --add-flags "-u ${vimrcAndPlugins}"
    wrapProgram $out/bin/gvim --add-flags "-u ${vimrcAndPlugins}"
  '';
}
  
