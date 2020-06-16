{ ps ? import <nixpkgs>{} 
, buildEnv ? ps.buildEnv
, writeShellScriptBin ? ps.writeShellScriptBin
}:
buildEnv {
  name = "nixEnv";
  paths = 
  [
    (writeShellScriptBin "nb" ''nix-build $@'')
    (writeShellScriptBin "ns" ''nix-shell $@'')
    (writeShellScriptBin "nrepl" "nix repl '<nixpkgs>'")
  ];
}
