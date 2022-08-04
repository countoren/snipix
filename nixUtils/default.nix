{ pkgs ? import <nixpkgs>{} 
, lib  ? pkgs.lib
, writeShellScript ? pkgs.writeShellScript
, runCommand ? pkgs.runCommand
, browser ? "${pkgs.firefox}/bin/firefox"
, xclip ? "${pkgs.xclip}/bin/xclip -selection c"
, perl ? "${pkgs.perl}/bin/perl"
, jq ? "${pkgs.jq}/bin/jq"
, less ? "${pkgs.less}/bin/less"
, vifm ? "${pkgs.vifm}/bin/vifm"
, git ? "${pkgs.git}/bin/git"
, user ? "exampleUser"
, prefix ? "onix"
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

  commands = 
  lib.attrValues (lib.fix (self: lib.mapAttrs writeShellScript (
  {
    #General
    projectFolder = getGitRootFolder;
    #NixOS general utils scripts
    install-system  = ''nixos-rebuild switch --flake "$@" .#'';

    install-home = ''nix build .#homeManagerConfigurations.${user}.activationPackage && ./result/activate'';

    #flake repl
    repl-basic = ''echo "$@" > repl.nix && nix repl ./repl.nix'';
    repl = ''${self.repl-basic} '${getFlakes}' '';
    replpkgs = ''${self.repl-basic} '(import ${getFlakes}.inputs.nixpkgs { system = builtins.currentSystem; })'"$@" '';
    replconfig = ''${self.repl} '.nixosConfigurations.${user}.config'$@ '';
    reploptions = ''${self.repl} '.nixosConfigurations.${user}.options'$@ '';

    edit = ''nix edit "$@"'';

    nfupdate = ''nix flake lock --update-input $@'';

    nclean = ''sudo nix-env -p /nix/var/nix/profiles/system --delete-generations +2'';

    search-oneline = ''nix search "$@" | ${perl} -ne 'if (!/^$/) { chomp } print' '';
    pkg-parse = ''sed  's/\* \(\S*\).*/\1/' '';
    pkg-name = ''sed  's/\* legacyPackages.${pkgs.system}\.\(\S*\).*/\1/' '';


    eval = ''nix eval "$@"'';

    search-pkgs = ''${self.search} nixpkgs | ${self.pkg-name} '';
    pkg-meta = ''${self.eval} --json nixpkgs#"$@".meta '';
    pkg-meta-color = ''${self.pkg-meta} "$@" | ${jq} -C'';
    search = ''
      ${self.search-oneline} "$@" | ${fzf} \
      --bind="ctrl-r:execute:${self.replpkgs} "'.`echo {} | ${self.pkg-name}`' \
      --bind="ctrl-b:execute:${self.open-homepage} ""$@"'#`echo {} | ${self.pkg-name}`' \
      --preview="${self.pkg-meta-color} "'`echo {} | ${self.pkg-parse}`' 
    '';

    find-insertions-points = ''
      ${git} grep -n -P '${toUpper prefix}\s*-\s*\w*' $(${self.projectFolder})"/**.nix" | ${fzf} -1 -0 
    '';

    open-homepage =''
        ${browser} "$(${self.eval} --raw "$@"'.meta.homepage')" 
    '';

    #create function that search in nixpkgs source folder
    #create function to open package in nix shell
    #create function to edit package 
    #create function to build package 

    # nix-build && ./result/bin/onix | sed 's/^\([^:]*\).*/\1/g' |   
    insert-pkg = ''sed -z 's/\(#ONIX - nixos p1n3\)\([[:space:]]\+\)\(.*#ONIX END\)/\1\2jq\2\3/g' '';
    onix = self.find-insertions-points;
  } 
  )));
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
