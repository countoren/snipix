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
# offline mod: #nix-build --option substitute false
# nix-instantiate  --eval -E 'builtins.attrNames (import <nixpkgs> {})' | jq | fzf
# nix-instantiate  --strict --eval -E '(import <nixpkgs> {}).hello.meta' |fzf
# vim insert word from terminal command under curosor

  ];
}
