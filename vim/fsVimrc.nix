{ pkgs? import <nixpkgs>{}
, pkgsPath ? toString  (import ../pkgsPath.nix)
, additionalVimrc? "" 
}:
import ./vimrcConfig.nix {
  inherit pkgs pkgsPath;
  additionalPlugins = with pkgs.vimPlugins;[
    LanguageClient-neovim
    (pkgs.vimUtils.buildVimPluginFrom2Nix {
        name = "ionide-vim";
        src = pkgs.fetchFromGitHub {
          owner = "ionide";
          repo = "Ionide-vim";
          rev = "a66845162ae4c2ad06d76e003c0aab235aac2ede";
          sha256 = "sha256-dbOutPgG+o9NGUtpYxla80B0XByvV5oig+5zqAQcOMI=";
        };
    })
  ];
  additionalVimrc = ''
    command! FSharpFormatThisFile :w | silent exec "!cd %:h && DOTNET_ROOT=$(dirname $(realpath $(which dotnet))) dotnet fantomas %:p" | e

    let g:fsharp#backend = "languageclient-neovim"
    let g:fsharp#fsautocomplete_command = ['dotnet','fsautocomplete']
    "F# interactive key bindings
    let g:fsharp#fsi_keymap = "custom"
    let g:fsharp#fsi_keymap_send   = "<leader>i"
    let g:fsharp#fsi_keymap_toggle = "<leader><shift-i>"
    let g:fsharp#fsi_extra_parameters = ['--langversion:preview', '--targetprofile:netcore']
    " Language server key bindings
    function! LC_maps()
      if has_key(g:LanguageClient_serverCommands, &filetype)
        nnoremap <F5> :call LanguageClient_contextMenu()<CR>
        nnoremap <silent> K :call LanguageClient#textDocument_hover()<CR>
        nnoremap <silent> gd :call LanguageClient#textDocument_definition()<CR>
        nnoremap <silent> gr :call LanguageClient#textDocument_references()<CR>
        nnoremap <silent> gn :call LanguageClient#textDocument_rename()<CR>
        nnoremap <leader>f :call LanguageClient_textDocument_codeAction()<CR>
        nnoremap <leader>k :call LanguageClient#explainErrorAtPoint()<CR>
        nnoremap <leader>e :call LanguageClient#diagnosticsNext()<CR>
        nnoremap <leader>E :call LanguageClient#diagnosticsPrevious()<CR>
        command! Symbols :call LanguageClient_textDocument_documentSymbol()
        command! Fix :call LanguageClient_textDocument_codeAction()
        nnoremap <leader>w :FSharpFormatThisFile<CR>
        nnoremap <leader>ld :call LanguageClient#textDocument_definition()<CR>
        nnoremap <leader>lr :call LanguageClient#textDocument_rename()<CR>
        nnoremap <leader>lt :call LanguageClient#textDocument_typeDefinition()<CR>
        nnoremap <leader>lx :call LanguageClient#textDocument_references()<CR>
        nnoremap <leader>la :call LanguageClient_workspace_applyEdit()<CR>
        nnoremap <leader>lc :call LanguageClient#textDocument_completion()<CR>
        nnoremap <leader>lh :call LanguageClient#textDocument_hover()<CR>
        nnoremap <leader>ls :call LanguageClient_textDocument_documentSymbol()<CR>
        nnoremap <leader>lm :call LanguageClient_contextMenu()<CR>
      endif
    endfunction
    autocmd FileType * call LC_maps()
  ''+ additionalVimrc;
}

