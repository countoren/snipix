{ pkgs ? import <nixpkgs>{}
, vifm ? pkgs.vifm
, pkgsPath ? toString  (import ../pkgsPath.nix)
, additionalPlugins? []
, additionalVimrc? "" 
}:
with pkgs;
let 
  insideVimVifm = pkgs.symlinkJoin {
    name = "vifm-wrapped";
    paths = [ vifm ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/vifm \
      --add-flags '-c "set vicmd=vsp"' \
      --add-flags ' .'
      #shorter the name for easy of use and remove conflicts
      mv $out/bin/vifm $out/bin/vf 
    '';
  }; 
  my_plugins = builtins.attrValues (import ./plugins.nix { inherit vimUtils fetchFromGitHub; });
in 
{
  customRC = ''
    let $MYVIMRC = '${pkgsPath}/vim/vimrc'
    let $VIMFolder = '${pkgsPath}/vim'
    let $MYPKGS = '${pkgsPath}'
    let $EDITOR = 'sp'
    let $PATH = "${insideVimVifm}/bin:".$PATH

    " VIM Shell
    set shell=${pkgs.zsh}/bin/zsh

    "Start terminal if not open in file
    autocmd VimEnter * if empty(bufname(''')) | cd $MYPKGS | endif
    autocmd VimEnter * if empty(bufname(''')) | exe "terminal" | endif
    autocmd BufEnter * let buf=bufname() | if isdirectory(buf) | exec 'terminal' | call feedkeys('icd '.buf."\<CR>") | endif

    let g:ctrlp_working_path_mode=""
    ''
    + (builtins.readFile ./vimrc) + ''
    "My Nix pkgs
    command! DPkgs silent :sp $MYPKGS
    "Vim folder
    command! DVim silent :sp $MYPKGS/vim
    "VIMRC
    command! FVimrc silent :sp $MYVIMRC

    ''
    + (if additionalVimrc == "" then "" else ''
    "Env Specific configuration:
    ''+ additionalVimrc);

    

    packages.myPackages = with pkgs.vimPlugins;
    {
      start = [

      # Style
      vim-colorschemes
      vim-airline
      vim-airline-themes

      # Errors showing 
      ale

      # Global Search
      ctrlp

      # Editing
      surround
      commentary
      supertab  # needed to integrate UltiSnips and YouCompleteMe
      vim-snippets  # snippet database
      vim-lastplace
      indentLine
      treesj

      {
         plugin = LanguageClient-neovim;
         config = ''
          let $PATH = $PATH.":${pkgs.rnix-lsp}/bin"

          let g:LanguageClient_serverCommands = {
          \ 'nix': ['rnix-lsp']
          \ }
          " identLine
          " Dont conceal (json)
          let g:indentLine_setConceal = 0 

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
          '';
      }

      # Nix 
      { 
        plugin = vim-nix;
        config = ''
          " additonal help to vim-nix with cli statix(vim-nix uses it)
          let $PATH = "${pkgs.statix}/bin:".$PATH
          " origin :echo expand("statix fix --dry-run % > /tmp/diff") | vert diffpatch /tmp/diff

          function! NIX_maps()
            nnoremap <leader>ns :!statix fix --dry-run % > /tmp/diff"<CR>:vert diffpatch /tmp/diff<CR>
            nnoremap <leader>nss :!statix fix %<CR>
          endfunction
          autocmd FileType nix call NIX_maps()

          " TODO : nix-dead find dead code plugin

        '';
      }


      # Shell commands helper and file managers
      vim-eunuch
      vifm-vim

      # Git
      fugitive
      gitgutter

      # Misc
      # vimproc not sure if it is needed
      # vim-addon-mw-utils





      ] 
      ++ my_plugins 
      ++ additionalPlugins; 
    };
}
