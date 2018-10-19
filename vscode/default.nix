{ writeShellScriptBin, buildEnv, vscode-with-extensions, vscode-extensions, vscode-utils }:
{ keysbindingFile? ./keybindings.json, settingsFile? ./settings.json, vscodeMatketExtensions? []}:
let
  keybindings = builtins.toFile "keybindings" (builtins.readFile keysbindingFile);
  restoreKeybindings = writeShellScriptBin "vscode_restoreKeybindings" ''
      cp -rfv ${keybindings} ~/Library/Application\ Support/Code/User/keybindings.json
  '';
  saveKeybindings = writeShellScriptBin "vscode_saveKeybindings" ''
      cp -rfv ~/Library/Application\ Support/Code/User/keybindings.json ${builtins.toString(keysbindingFile)}
  '';

  settings = builtins.toFile "settings" (builtins.readFile settingsFile);
  restoreSettings = writeShellScriptBin "vscode_restoreSetting" ''
      cp -rfv ${settings} ~/Library/Application\ Support/Code/User/settings.json
  '';
  saveSettings = writeShellScriptBin "vscode_saveSettings" ''
      cp -rfv ~/Library/Application\ Support/Code/User/settings.json ${builtins.toString(settingsFile)}
  '';

in
{
  name = "vscode-env";
  buildInputs = [
    restoreKeybindings
    saveKeybindings
    restoreSettings
    saveSettings
    ( vscode-with-extensions.override {
      # When the extension is already available in the default extensions set.
      vscodeExtensions = with vscode-extensions; [
        bbenoist.Nix
      ]
      # Concise version from the vscode market place when not available in the default set.
      ++ (vscode-utils.extensionsFromVscodeMarketplace vscodeMatketExtensions );
      }
    )
  ];

  shellHook = '' 
    vscode_restoreKeybindings 
    vscode_restoreSetting
    #this allow VSCode with vim plugin to repeated motions strokes when holding motions keys (hjkl)
    defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false 
  '';
}
