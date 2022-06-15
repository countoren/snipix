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
, prefix ? "onix"
, fzf ? ''${pkgs.fzf}/bin/fzf -i -e +s \
        --reverse \
        --ansi \
        --tiebreak=index \
        --bind "ctrl-J:down" \
        --bind "ctrl-K:up"''
}:
let 

  commands = 
  lib.attrValues (lib.fix (self: lib.mapAttrs writeShellScript (
  {
    search-oneline = ''nix search "$@" | ${perl} -ne 'if (!/^$/) { chomp } print' '';
    pkg-parse = ''sed  's/\* \S*\.\(\S*\).*/\1/' '';

    search-pkgs = ''${self.search} nixpkgs '';
    pkg-meta = ''nix eval --json nixpkgs#"$@".meta | ${jq}'';
    search = ''${self.search-oneline} "$@" | ${fzf} --preview="${self.pkg-meta} "'`echo {} | ${self.pkg-parse}`' '';

    onix = ''${self.search-oneline} "$@" | ${fzf} --preview="(${self.pkg-meta} "'`echo {} | ${self.pkg-parse}`'") | ${jq} -r '.homepage'" '';

    # onix = '' 
    #  ${browser} $(${self.pkg-meta} jq  | ${jq} -r ".homepage")
    # '';

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
