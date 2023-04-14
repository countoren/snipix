{pkgs ? import <nixpkgs>{}
}:
pkgs.symlinkJoin {
  name = "myGrep";
  paths = [
  (pkgs.writeShellScriptBin "rg-basic" ''
    ${pkgs.ripgrep}/bin/rg "$@"
  '')
  (pkgs.writeShellScriptBin "rg" ''
    ${pkgs.ripgrep}/bin/rg --color ansi --vimgrep "$@"
  '')
  ];
}
