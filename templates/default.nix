{ pkgs ? (builtins.getFlake (toString ../.)).inputs.nixpkgs.legacyPackages.${builtins.currentSystem}
, templates ? import ./templates.nix
# Prefix to be appended to all 
, prefix ? "sx"

, nix ? "${pkgs.nix}/bin/nix"
, lib ? pkgs.lib
, writeShellScriptBin ? pkgs.writeShellScriptBin

, git ? "${pkgs.git}/bin/git"
# This string is repesenting the absolute pass of your templates folder
# if use in standalone the path could be brought by this command
# otherwise replace with hardcoded string path (will be used in a shell script)
, templatesFolder ? ''$(${git} rev-parse --show-toplevel)''

, highlight ? "${pkgs.highlight}/bin/highlight"
, fzf ? "${pkgs.fzf}/bin/fzf"
# this command will be fed ($1) with the directory containing snippets should prompt the users for chosing snippet 
, listAndSelectTool? pkgs.writeShellScript "select" ''
  find $1 -type f -not -path './.git/*' | ${fzf} -1 --preview="${highlight} -O ansi {}"       
''
# this command will be fed by a file chosed by the user which contain the snippet
, snipTool ? pkgs.writeShellScript "snipTool" ''cat $1 | ${pkgs.xclip}/bin/xclip -selection c && cat $1''

# Default nix install command for stand alone templates(not with Nixos or HomeManager)
# The command should be fed as a string with references in order to feed it into writeShellScript
# if used in nixos should be replaced with something like nixos-rebuild switch ...
, installCommand ? ''
    ${nix} profile remove $(${nix} profile list | grep '${prefix}$' | cut -d ' ' -f 4)
    ${nix} profile install -f ${templatesFolder}/default.nix
''
# a difftool that will be fed with 2 filepath to compare in case of conflict
# between a target file and a template file
, difftool ? pkgs.writeShellScript "vimdiff" ''
  ${pkgs.vim}/bin/vimdiff $1 $2
''
}:
let commands = lib.fix (self: lib.mapAttrs pkgs.writeShellScript 
  ({
    utils-install-command = installCommand;
    init = ''
      ${nix} flake init -t ${templatesFolder}\#$1
    '';

    snip = ''
     ${snipTool} $(${listAndSelectTool} ${templatesFolder}/$1 )
    '';

    init-with-diff = ''
      echo 'merge conflict files running the following command:'
      echo "${difftool} $1 $2"
        
      ${self.init} $1 2>&1 | grep 'refusing\|merge' | awk '{ print $NF }' | xargs -n 2 ${difftool}
    '';

    save-basic = ''
      echo "creating template folder $1 and copying the current folder into it..."
      mkdir -p ${templatesFolder}/$1 
      cp -r . ${templatesFolder}/$1 

      [[ "$INPUT" == "y" ]] && $EDITOR ${templatesFolder}/$1 && \
      echo 'Waiting, press any key to contine...' && read -n1 K 

      echo "cd into templates and adding folder to git"
      pushd ${templatesFolder}
      ${git} add $1
      echo "cd back to last folder"
      popd

      echo "Inserting $1 into the templates list"
      echo "// { $1 = { description = \"$2\"; path = ./$name; }; }" >> ${templatesFolder}/templates.nix

      ${self.utils-install-command} 
    '';

    save-p = ''
      read -p "Template Name:" name 
      read -p "Template Desc:" desc 
      echo 'Edit Files?[press y to edit or any key otherwise]'
      read -n1 INPUT
      ${self.save-basic} $name $desc $INPUT
    '';
    utils-get-flake-desc = "${nix} flake metadata  | grep 'Description' | sed 's/Description.*//' ";
    save = ''
      name=$(basename `pwd`)
      desc=$(${self.utils-get-flake-desc})
      INPUT="n"
      ${self.save-basic} $name $([[ ! -z $desc ]] || echo 'N/A') $input
    '';
    save-edit = ''
      name=$(basename `pwd`)
      desc=$(${self.utils-get-flake-desc})
      INPUT="y"
      ${self.save-basic} $name $([[ ! -z $desc ]] || echo 'N/A') $input
    '';

  } // lib.attrsets.concatMapAttrs (name: { description, path }: {
    "${name}" = '' ${self.init-with-diff} ${name} '';
    "snip-${name}" = ''${self.snip} ${name}'';
    "${name}-edit" = ''$EDITOR ${templatesFolder}/${name} '';
    "${name}-noDiff" = '' ${self.init} ${name} '';
    "${name}-description" = '' echo "${description}" '';
  }) templates)

);
# nix build -f default.nix --argstr templatesFolder /home/p1n3/nixpkgs/templates 
in lib.fix (self: pkgs.symlinkJoin {
  name = prefix;
  passthru.commands = lib.mapAttrs (name: pkgs.writeShellScriptBin "${prefix}-${name}") commands;
  paths = lib.attrValues self.passthru.commands;
})
