{ pkgs ? import <nixpkgs>{} 
, lib  ? pkgs.lib
, writeShellScript ? pkgs.writeShellScript
, runCommand ? pkgs.runCommand
, browser ? "${pkgs.firefox}/bin/firefox"
, xclip ? "${pkgs.xclip}/bin/xclip -selection c"
, perl ? "${pkgs.perl}/bin/perl"
, sd ? "${pkgs.sd}/bin/sd"
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
        --bind "alt-j:down" \
        --bind "alt-k:up" \
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
    install-system  = ''${self.create-nix-path} && nixos-rebuild switch --flake "$@" .#'';

    install-home = ''nix build .#homeManagerConfigurations.${user}.activationPackage && ./result/activate'';

    # Registry 
    
    # assuming this format
    # global flake:sops-nix github:Mic92/sops-nix
    regBasic = '' nix registry list '';
    getRegName = ''
      awk '{ print $2 }' | cut -d':' -f2
    '';
    onlyUserRegNoNixpkgs = ''
      grep "^user" | grep -v 'nixpkgs'
    '';
    regsNames = ''
      ${self.regBasic} | ${self.getRegName}
    '';

    createRegLocal = ''
      nix registry add $(${self.projectFolder})
    '';
    reg = ''
      ${self.regBasic} | ${self.onlyUserRegNoNixpkgs} | ${fzf} \
      --preview="nix flake show "'`echo {} | ${self.getRegName}`' 
    '';

    #Flakes
    show = ''
      nix flake show "$@"
    '';

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

    create-nix-path = ''
      pkgsPath=$(${self.projectFolder})
      echo "$pkgsPath" > $pkgsPath/pkgsPath.nix
    '';

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
    find-insertion-points-file-only = ''
      ${self.find-insertions-points} | awk -F ':' '{print $1}'
    '';

    open-homepage =''
        ${browser} "$(${self.eval} --raw "$@"'.meta.homepage')" 
    '';


    #create function that search in nixpkgs source folder
    #create function to open package in nix shell
    #create function to edit package 
    #create function to build package 

    #split-on-comment-section-help = '' echo '\1 - before pkgs \2 - spaces \3 - pkgs \4 - tail' '';
    split-on-comment-section-help = ''
      ${sd} --help
      '';
    #split-on-comment-section = ''sed -z "s;\(.*#${toUpper prefix}[^/]*\n\)\([\s\t]\+\)\(.*\)\(#${toUpper prefix} END.*\);$1;g" $2'';
    #split-on-comment-section = ''${perl} -i -pe "s/\(.*#${toUpper prefix} - nixos p1n3.*?\n\)/$1/g" $2'';
    split-on-comment-section = ''
       ${sd} -p "(p1n3.*)(#${toUpper prefix} - nixos p1n3)" '$1' ../flake.nix
      '';

    #split-on-comment-section = ''sed -z 's/\(#${toUpper prefix} - nixos p1n3\)\([[:space:]]\+\)\(.*#${toUpper prefix} END\)/\1\2jq\2\3/g' $(${self.find-insertion-points-file-only})'';

    show-pkgs = ''
      ${self.split-on-comment-section} "\3" $1
    '';



    onix = self.show-pkgs;
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
