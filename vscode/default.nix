{ lib, writeShellScriptBin, writeTextFile, callPackage, buildEnv, vscode, vscode-with-extensions, vscode-extensions, vscode-utils }:
{ keysbindingFile? ./keybindings.json, 
  settingsFile? ./settings.json, 
  additionalPostFixup? '''', 
  vscodeMatketExtensions? [] 
}:
let
  #Helpers
  keybindings = builtins.toFile "keybindings" (builtins.readFile keysbindingFile);
  restoreKeybindings = writeShellScriptBin "vscode_restoreKeybindings" ''
      cp -rfv ${keybindings} ~/Library/Application\ Support/Code/User/keybindings.json
  '';
  saveKeybindings = writeShellScriptBin "vscode_saveKeybindings" ''
      cp -rfv ~/Library/Application\ Support/Code/User/keybindings.json ${builtins.toString(keysbindingFile)}
  '';

  settingsStr = 
  if lib.hasSuffix ".nix" settingsFile then callPackage (import settingsFile) {}
  else (builtins.readFile settingsFile);
  settings = writeTextFile { name = "settings"; text = settingsStr; };
  restoreSettings = writeShellScriptBin "vscode_restoreSetting" ''
      cp -rfv ${settings} ~/Library/Application\ Support/Code/User/settings.json
  '';
  saveSettings = writeShellScriptBin "vscode_saveSettings"
  (if lib.hasSuffix ".nix" settingsFile then ''
      echo 'source setting file is a nix function please update manually in:'
      echo '${builtins.toString(settingsFile)}'
  ''
  else ''
      cp -rfv ~/Library/Application\ Support/Code/User/settings.json ${builtins.toString(settingsFile)}
  '');

  #VSCode
  createVscodeWithExtensions = import <nixpkgs/pkgs/applications/editors/vscode/with-extensions.nix> ;
  vscodeWithNewPostFixup = vscode.overrideDerivation (old: {
    postFixup = old.postFixup + additionalPostFixup;
  });
  vscode2 =
    callPackage createVscodeWithExtensions {
      vscodeExtensions = with vscode-extensions; [
        bbenoist.Nix
      ]
      # Concise version from the vscode market place when not available in the default set.
      ++ (vscode-utils.extensionsFromVscodeMarketplace vscodeMatketExtensions );
      vscode = vscodeWithNewPostFixup;
    };
in
{
  buildInputs = [
    restoreKeybindings
    saveKeybindings
    restoreSettings
    saveSettings
    vscode2
  ];

  shellHook = '' 
    vscode_restoreKeybindings 
    vscode_restoreSetting
    #this allow VSCode with vim plugin to repeated motions strokes when holding motions keys (hjkl)
    defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false 
  '';
}
