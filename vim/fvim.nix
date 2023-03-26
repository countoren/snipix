{ pkgs ? (builtins.getFlake (toString ./.)).inputs.nixpkgs.legacyPackages.${builtins.currentSystem}
, pkgsPath ? toString (import ../pkgsPath.nix)
, additionalVimrc?  ""
}:
import ./nvim.nix {
  inherit pkgs;
  prefix = "fvim";
  vimrcConfig = import ./fsVimrc.nix { inherit pkgs pkgsPath; };
}
/*

let fnvim = import ./nvim {
  prefix = "fnvim";
  additionalVimrc = ''
    
  '' + additionalVimrc;
};
in 


{ pkgs ? (builtins.getFlake (toString ../.)).inputs.nixpkgs.legacyPackages.${builtins.currentSystem}
, lib ? pkgs.lib
, gitDrv ? pkgs.git
, fzf ? "${pkgs.fzf}/bin/fzf"
, pkgsPath ? toString (import ../pkgsPath.nix)
, additionalVimrc? ''

set guifont=DejaVu\ Sans\ Mono:h15


''
, vimrcConfig ? import ./vimrcConfig.nix { inherit pkgs pkgsPath additionalVimrc;  }
, prefix? "nvim"
}:
pkgs.symlinkJoin {
  name = "fvim";
  paths = [
    (import ./nvim.nix { inherit pkgs;})
    (pkgs.callPackage ./fvim-basic.nix {})
  ];
  buildInputs = [ pkgs.makeWrapper ];
  postBuild = ''
    wrapProgram $out/bin/fvim --add-flags "-mvim ${vimrcAndPlugins}"
  '';
}
*/
