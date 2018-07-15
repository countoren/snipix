{ pkgs, name, vimrcDrv, vimSize? "normal" }:
with pkgs; 
let
  configurable_nix_path = <nixpkgs/pkgs/applications/editors/vim/configurable.nix>;
  my_vim_configurable = vimUtils.makeCustomizable (callPackage configurable_nix_path {
    inherit (darwin.apple_sdk.frameworks) CoreServices Cocoa Foundation CoreData;
    inherit (darwin) libobjc cf-private;

    #overide complation configurations
    features = vimSize; # one of  tiny, small, normal, big or huge
    lua = pkgs.lua5_1;
    gui = config.vim.gui or "auto";
    python = python3;

    # optional features by flags
    flags = [ "python" "X11" ];
  });

in  
vimUtils.vimWithRC {
  name = name;
  vimExecutable = "${my_vim_configurable}/bin/vim";
  vimrcFile = vimrcDrv;
}
