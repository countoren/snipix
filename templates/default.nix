{ pkgs ? (builtins.getFlake (toString ../.)).inputs.nixpkgs.legacyPackages.${builtins.currentSystem}
, templates ? import ./templates.nix
# Prefix to be appended to all 
, prefix ? "tmp"
# This string is repesenting the absolute pass of your templates folder
# if use in standalone the path could be brought by this command
# otherwise replace with hardcoded string path (will be used in a shell script)
, templatesFolder ? ''$(${git} rev-parse --show-toplevel)''
, nix ? "${pkgs.nix}/bin/nix"

, highlight ? "${pkgs.highlight}/bin/highlight"
, fzf ? "${pkgs.fzf}/bin/fzf"
# this command will be fed ($1) with the directory containing snippets should prompt the users for chosing snippet 
, listAndSelectTool? pkgs.writeShellScript "select" ''
  find $1 -type f -not -path './.git/*' | ${fzf} -1 --preview="${highlight} -O ansi {}"       
''

# Default nix install command for stand alone templates(not with Nixos or HomeManager)
# The command should be fed as a string with references in order to fed into writeShellScript
# if used in nixos should be replaced with something like nixos-rebuild switch ...
, installCommand ? ''
    ${nix} profile remove $(${nix} profile list | grep '${prefix}$' | cut -d ' ' -f 4)
    ${nix} profile install -f ${templatesFolder}/default.nix
''
, lib ? pkgs.lib
, writeShellScriptBin ? pkgs.writeShellScriptBin
, git ? "${pkgs.git}/bin/git"
# a difftool that will be fed with 2 filepath to compare in case of conflict
# between a target file and a template file
, difftool ? pkgs.writeShellScript "vimdiff" ''
  ${pkgs.vim}/bin/vimdiff $1 $2
''
# this command will be fed by a file chosed by the user which contain the snippet
, snipTool ? pkgs.writeShellScript "snipTool" ''cat $1 | ${pkgs.xclip}/bin/xclip -selection c && cat $1''
# , difftool ? pkgs.writeShellScript "vimdiff" ''
#       nvim-client-send "tabe $1 | vert diffs $2" 
# ''

, templateWithDiff ? { templatesAddress, difftool}: templateName: ''
    ${nix} flake init -t ${templatesAddress}\#${templateName} 2>&1 | grep 'refusing\|merge' | awk '{ print $NF }' | xargs -n 2 ${difftool} 
''
}:
let commands = lib.fix (self: lib.mapAttrs pkgs.writeShellScript 
  ({
    inherit installCommand;
    init = ''
      ${nix} flake init -t ${templatesFolder}\#$1
    '';

    snip = ''
     ${snipTool} $(${listAndSelectTool} ${templatesFolder}/$1 )
    '';

    initWithDiff = ''
      echo 'merge conflict files running the following command:'
      echo "${difftool} $1 $2"
        
      ${self.init} $1 2>&1 | grep 'refusing\|merge' | awk '{ print $NF }' | xargs -n 2 ${difftool}
    '';

    save-template = ''
      read -p "Template Name:" name 
      read -p "Template Desc:" desc 

      echo "creating template folder $name and copying the current folder into it..."
      mkdir -p ${templatesFolder}/$name 
      cp -r . ${templatesFolder}/$name 

      echo 'Edit Files?[press y to edit or any key to continue]'
      read -n1 INPUT && [[ "$INPUT" == "y" ]] && $EDITOR ${templatesFolder}/$name && \
      echo 'Waiting, press any key to contine...' && read -n1 K 

      echo "cd into templates and adding folder to git"
      pushd ${templatesFolder}
      ${git} add $name
      echo "cd back to last folder"
      popd

      echo "Inserting $name into the templates list"
      echo "// { $name = { description = \"$desc\"; path = ./$name; }; }" >> ${templatesFolder}/templates.nix

      ${self.installCommand} 
    '';
  } // lib.attrsets.concatMapAttrs (name: { description, path }: {
    "${prefix}-${name}" = '' ${self.initWithDiff} ${name} '';
    "snip-${name}" = ''${self.snip} ${name}'';
    "${prefix}-${name}-edit" = ''$EDITOR ${templatesFolder}/${name} '';
    "${prefix}-${name}-noDiff" = '' ${self.init} ${name} '';
    "${prefix}-${name}-description" = '' echo "${description}" '';
  }) templates)

);
# nix build -f default.nix --argstr templatesFolder /home/p1n3/nixpkgs/templates 
in lib.fix (self: pkgs.symlinkJoin {
  name = prefix;
  passthru.commands = lib.mapAttrs pkgs.writeShellScriptBin commands;
  paths = (lib.attrValues self.passthru.commands);
})
