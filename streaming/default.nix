{ pkgs ? import <nixpkgs>{} 
, streamingApp ? import ./obs-stream-darwin.nix { inherit pkgs;}
} :
pkgs.buildEnv {
  name = "streaming tools";
  paths = [
    streamingApp
    (pkgs.writeShellScriptBin "obs" ''
        open ${streamingApp}/Applications/*.app
    '')
  ];
}

