{ name, additionalPlugins? [], additionalCustPlugins? {} ,
  #dependencies
  stdenv
}:
let app = 
  with stdenv; import ./vim/macvim.nix { 
    inherit mkDerivation fetchFromGitHub; 
    name = "app_"+name;
  };
vimrcDrv = import ./VimrcAndPlugins.nix { inherit pkgs additionalPlugins additionalCustPlugins;};
in writeShellScriptBin name ''${app}/bin/mvim -u ${vimrcDrv} "$@"''
