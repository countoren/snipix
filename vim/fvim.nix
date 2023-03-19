{ pkgs ? (builtins.getFlake (toString ./.)).inputs.nixpkgs.legacyPackages.${builtins.currentSystem}
} :

pkgs.callPackage ./fvim-basic.nix {}
/*
pkgs.symlinkJoin {
  inherit name;
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
