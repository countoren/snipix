{ name, additionalPlugins? [], additionalCustPlugins? {} ,
  pkgs? import <nixpkgs>{}
}:
with pkgs;
let app = 
  with stdenv; import ./macvim.nix { 
    inherit mkDerivation fetchFromGitHub; 
    name = "app_"+name;
  };
vimrcDrv = import ./VimrcAndPlugins.nix { inherit pkgs additionalPlugins additionalCustPlugins;};
in writeShellScriptBin name ''${app}/bin/mvim -u ${vimrcDrv} "$@"''
