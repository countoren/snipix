{ pkgs ? import <nixpkgs> {} 
, vimrcAndPlugins ? import ./VimrcAndPlugins.nix { inherit pkgs; }
, name ? "lvim"
}:
pkgs.symlinkJoin {
  inherit name;
  paths = [ (pkgs.vim_configurable.override { python = pkgs.python3; }) ];
  buildInputs = [ pkgs.makeWrapper ];
  postBuild = ''
    makeWrapper $out/bin/vim $out/bin/${name} \
      --add-flags "-u ${vimrcAndPlugins}"
  '';
}
  
