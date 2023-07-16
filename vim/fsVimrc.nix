{ pkgs ? (builtins.getFlake (toString ../.)).inputs.nixpkgs.legacyPackages.${builtins.currentSystem}
, dotnet ? "${pkgs.dotnet-sdk}/bin/dotnet"
}:
with pkgs.vimPlugins; [
deoplete-nvim
deoplete-lsp 
{
  plugin = Ionide-vim;
  # pkgs.vimUtils.buildVimPluginFrom2Nix {
  #       name = "ionide-vim";
  #       src = pkgs.fetchFromGitHub {
  #         owner = "ionide";
  #         repo = "Ionide-vim";
  #         rev = "a66845162ae4c2ad06d76e003c0aab235aac2ede";
  #         sha256 = "sha256-dbOutPgG+o9NGUtpYxla80B0XByvV5oig+5zqAQcOMI=";
  #       };
  #   };
  # Expecting: LanguageClient-neovim
  config = ''
    let g:LanguageClient_serverCommands['fsharp'] = ['dotnet', 'fsautocomplete']

    let $DOTNET_ROOT="${pkgs.dotnet-sdk}"
    let $PATH = "${pkgs.dotnet-sdk}/bin:".$PATH
    let $PATH = "$HOME/.dotnet/tools:".$PATH
    let g:deoplete#enable_at_startup = 1

    command! FSharpFormatThisFile :w | silent exec "!cd %:h && DOTNET_ROOT=$(dirname $(realpath $(which dotnet))) dotnet fantomas %:p" | e

    let g:fsharp#backend = "languageclient-neovim"
    let g:fsharp#fsautocomplete_command = ['dotnet','$HOME/.dotnet/tools/fsautocomplete']
    "F# interactive key bindings
    let g:fsharp#fsi_keymap = "custom"
    let g:fsharp#fsi_keymap_send   = "<leader>i"
    let g:fsharp#fsi_keymap_toggle = "<leader><shift-i>"
  '';
  filetypes = [ "fsharp" ];
}
]
