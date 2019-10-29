{  pkgs ? import <nixpkgs> {} 
,  vimrcWithPlugins ? import ./VimrcAndPlugins.nix { inherit pkgs; }
# , ps1803drv ? import ../nixpkgs1803.nix
# , ps1803 ? import ps1803drv {}
# , vimConfigurableFile ? import "${ps1803drv}/pkgs/applications/editors/vim/configurable.nix" 
# , vimConfigurableFile ? import <nixpkgs/pkgs/applications/editors/vim/configurable.nix> 
# , vimConfigurableFile ? import ./configurable.nix
, vimFunc ? import <nixpkgs/pkgs/applications/editors/vim>
}:
with pkgs;
let baseVim = (callPackage vimFunc {
  inherit (darwin.apple_sdk.frameworks) Cocoa Carbon;
}).overrideDerivation (self : {
  buildInputs = self.buildInputs ++ [ python37 ];
  configureFlags = self.configureFlags ++
  [
    #python support
    "--enable-python3interp=yes"
    "--with-python3-config-dir=${python37}/lib"
    "--with-python3-command=python3.7"

    #lua support
    "--with-lua-prefix=${lua}"
    "--enable-luainterp"
  ];
});
in 
symlinkJoin {
  name = "ovim";
  paths = [ baseVim ];
  buildInputs = [ makeWrapper ];
  postBuild = ''
    makeWrapper $out/bin/vim $out/bin/ovim \
      --add-flags "-u ${vimrcWithPlugins}"
  '';
}
  
# vim_configurable.override (
# {feature
#    features = "big"; # one of  tiny, small, normal, big or huge
#    lua = pkgs.lua5_1;
#    gui = "gtk2";
#    python = python3;
#    # optional features by flags
#    flags = [ "python" "X11" ];

# })


# working
# pkgs.callPackage (import ./bla.nix ) 
# { 
#   stdenv = pkgs.stdenv; 
#   inherit (darwin.apple_sdk.frameworks) Cocoa Carbon;
#   vimrc = vimrcWithPlugins;
# }


#vim_configurable.override {
#    buildInputs = vim_configurable.buildInputs++ [ gtk3 ];
#    inherit (darwin.apple_sdk.frameworks) CoreServices Cocoa Foundation CoreData;
#    inherit (darwin) libobjc cf-private;

#    #overide complation configurations
#    features = "big"; # one of  tiny, small, normal, big or huge
#    lua = pkgs.lua5_1;
#    gui = config.vim.gui or "auto";
#    python = python3;

#    # optional features by flags
#    flags = [ "python" "X11" ];
#}
#vimUtils.makeCustomizable (callPackage vimConfigurableFile {
#    inherit (darwin.apple_sdk.frameworks) CoreServices Cocoa Foundation CoreData;
#    inherit (darwin) libobjc cf-private;

#    #overide complation configurations
#    features = "big"; # one of  tiny, small, normal, big or huge
#    lua = pkgs.lua;
#    python = python37;

#    # darwinSupport = true;

#    # optional features by flags
#    flags = [ "python"  ];
#  })
