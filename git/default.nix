{ ps ? import <nixpkgs>{} 
, buildEnv ? ps.buildEnv
, git ? ps.git
, writeShellScriptBin ? ps.writeShellScriptBin
}:
buildEnv {
  name = "gitEnv";
  paths = 
  [
    git
    (writeShellScriptBin "gl" ''git log $@'')
    (writeShellScriptBin "ga" ''git add $@'')
    (writeShellScriptBin "gs" ''git status $@'')
    (writeShellScriptBin "gd" ''git diff $@'')
    (writeShellScriptBin "gc" ''git commit $@'')
    (writeShellScriptBin "gco" ''git checkout $@'')
    (writeShellScriptBin "gp" ''git push $@'')
  ];
}
