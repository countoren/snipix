{ pkgs ? import <nixpkgs>{} 
, lib  ? pkgs.lib
, writeShellScript ? pkgs.writeShellScript
, runCommand ? pkgs.runCommand
, git ? "${pkgs.git}/bin/git"
, diff-so-fancy ? "${pkgs.diff-so-fancy}/bin/diff-so-fancy"
, xclip ? "${pkgs.xclip}/bin/xclip -selection c"
, less ? "${pkgs.less}/bin/less"
, vifm ? "${pkgs.vifm}/bin/vifm"
, prefix ? "ogit"
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
  commands = 
  lib.attrValues (lib.fix (self: lib.mapAttrs writeShellScript (
  {
    commit = '' ${git} commit -m "$@" '';
    log-basic = ''
      ${git} log --graph --date=short --color=always \
      --format="%C(auto)%cd %h%d %s %C(magenta)[%an]%Creset"
      #--format="%C(cyan)%h %C(blue)%ar%C(auto)%d \
      #          %C(yellow)%s%+b %C(black)%ae" "$@"
    '';

    hash = ''
      grep -o '[a-f0-9]\{7\}' 
    '';

    split = ''
      ${git} subtree split --prefix=$1 -b $2
    '';
    subtree-add = ''
      ${git} subtree add --prefix $2 git@github.com:$1/$2.git master --squash
    '';

    show = ''
      ${git} show --color=always "$@"
    '';
    showFancy = ''
      ${self.show} "$@" | ${diff-so-fancy} | ${less} -r
    '';

 
    log-nopreview = ''
        ${self.log-basic} | ${fzf} \
        --no-multi \
        --header "enter: view,C-c: copy hash" \
        --bind "enter:execute:${self.showFancy} "'$(echo {} | ${self.hash})' \
        --bind "ctrl-c:execute:echo {} | ${self.hash} | ${xclip}" \
        "$@"
    '';
    log = ''
        ${self.log-nopreview} --preview="${self.showFancy} "'$(echo {} | ${self.hash})' \
        "$@"
    '';

    files-basic = ''
      ${git} ls-files --modified --others --exclude-standard
    '';
    files = ''
      ${self.files-basic} | ${fzf} -m \
         --preview="${git} diff {} | ${diff-so-fancy}" \
         --bind="enter:execute:sp {}" \
         --bind="ctrl-a:execute:${git} add -p {}"
    '';

    project-path = ''${git} rev-parse --show-toplevel'';

    status-basic = "${git} status -s";
    add-and-status = ''${git} add "$@" > /dev/null; ${self.status-basic}'';
    addp-and-status = ''${git} add -p "$@" > /dev/null; ${self.status-basic}'';
    reset-and-status = ''${git} reset "$@" > /dev/null; ${self.status-basic}'';
    vfiles = ''${vifm} --select "$@" $(${self.project-path})'';

    status = ''
      ${self.status-basic} | ${fzf} --no-sort \
      --header 'ctrl-a add, ctrl-r reset\n ctrl-h add -p, ctrl-H reset -p\n ctrl-i ignore, ctrl-s sp in vim' \
      --preview '${git} diff --color=always {+2} | ${diff-so-fancy}' \
      --bind="ctrl-a:reload:${self.add-and-status} {+2..}" \
      --bind="ctrl-r:reload:${self.reset-and-status} {+2..}" \
      --bind="ctrl-h:execute(${git} add -p {+2..})+reload:${self.status-basic}" \
      --bind="ctrl-H:execute(${git} reset -p {+2..})+reload:${self.status-basic}" \
      --bind="ctrl-i:execute(echo {+2..} >> .gitignore)+reload:${self.status-basic}" \
      --bind="ctrl-f:execute(${self.vfiles} {+2..})+reload:${self.status-basic}" \
      --bind="ctrl-s:execute:sp {+2..}" \
      --preview-window=right:60%:wrap
    '';
    edit = ''sp ${toString ./default.nix}'';
    ogit = self.status;


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
