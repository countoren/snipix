{ pkgs ? import <nixpkgs>{} 
, lib  ? pkgs.lib
, writeShellScript ? pkgs.writeShellScript
, runCommand ? pkgs.runCommand
, prefix ? "onm"
}:
let 
  commands = 
  lib.attrValues (lib.fix (self: lib.mapAttrs writeShellScript (
  {
    wifi-basic = ''nmcli radio wifi "$@"'';
    wifi-off = ''${self.wifi-basic} off'';
    wifi-on = ''${self.wifi-basic} on'';
    wifi = ''
      if [ $(${self.wifi-basic}) = 'enabled' ]; then ${self.wifi-off}; else ${self.wifi-on}; fi
    '';
    ${prefix} = self.wifi;
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
