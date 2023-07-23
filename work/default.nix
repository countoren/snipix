{ pkgs ? import <nixpkgs>{} 
, lib  ? pkgs.lib
, writeShellScript ? pkgs.writeShellScript
, runCommand ? pkgs.runCommand
, git ? "${pkgs.git}/bin/git"
, user ? "exampleUser"
, prefix ? "work"
, toUpper ? pkgs.lib.toUpper
, fzf ? ''${pkgs.fzf}/bin/fzf -i -e +s \
        --reverse \
        --ansi \
        --tiebreak=index \
        --bind "ctrl-J:down" \
        --bind "ctrl-K:up"''
}:
let 
  getGitRootFolder = ''${git} rev-parse --show-toplevel'';
  getFlakes = ''(builtins.getFlake "'$(${getGitRootFolder})'")'';
  ssh = ''${pkgs.openssh}/bin/ssh'';
  commands = 
  lib.attrValues (lib.fix (self: lib.mapAttrs writeShellScript
  {
    #General
    projectFolder = getGitRootFolder;
    sshDeltaServer = ''${ssh} $(whoami)"@"192.168.56.220'';
    sshFix1ProducationServer = ''${ssh} $(whoami)"@"192.168.61.238'';
    # anthony chomber's pdf
    sshFix1ProducationServerProdUser = ''${ssh} production"@"192.168.61.238'';
  }));
in
runCommand prefix {
  name = prefix;
  version = "1.0.0";
  }
  ''
    mkdir -p $out/bin
    ${lib.concatMapStringsSep " " (c: ''
      ln -nfs ${c} $out/bin/${
        if prefix == c.name then c.name else prefix+"-"+c.name
        }
    '') commands}
  ''
