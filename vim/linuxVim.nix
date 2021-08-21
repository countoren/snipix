{  pkgs ? import <nixpkgs> {} 
,  vimrcWithPlugins ? import ./VimrcAndPlugins.nix { inherit pkgs; }
}:
pkgs.symlinkJoin {
  name = "ovim";
  paths = [ (pkgs.vim_configurable.override { python = pkgs.python3; }) ];
  buildInputs = [ pkgs.makeWrapper ];
  postBuild = ''
    makeWrapper $out/bin/vim $out/bin/ovim \
      --add-flags "-u ${vimrcWithPlugins}"
  '';
}
  
