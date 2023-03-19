{ pkgs ? (builtins.getFlake (toString ./.)).inputs.nixpkgs.legacyPackages.${builtins.currentSystem}
}:
pkgs.callPackage ./fvim-basic.nix {}
