
" /*** CtrlP ***/
let g:ctrlp_custom_ignore = 'node_modules'

" /*** Vim Interface  ***/

set encoding=utf-8
set wildmenu
set ignorecase
set hls
set number relativenumber
set ruler
set showmatch
set ls=2
set iskeyword+=_,$,@,%,#  
set foldmethod=marker
" set backspace=2
set nocompatible

set cf  " Enable error files & error jumping.
set clipboard+=unnamedplus " Yanks go on clipboard instead.
set history=256  " Number of things to remember in history.
set autowrite  " Writes on make/shell commands
set timeoutlen=250  " Time to wait after ESC (default causes an annoying delay)
" colorscheme vividchalk  " Uncomment this to set a default theme

let &t_SI.="\e[5 q"
let &t_SR.="\e[4 q"
let &t_EI.="\e[1 q"

"adding more history (default 20)
set history=1000

"Formatting
set tabstop=4     " tabs are at proper location
set softtabstop=0 " number of spaces while inserting tabs
set expandtab     " don't use actual tab character (ctrl-v)
set shiftwidth=4  " indenting is 4 spaces
set smarttab
set autoindent    " turns it on
set smartindent   " does the right thing (mostly) in programs

""colorscheme
colorscheme wombat

"" Workarounf for gx (netrw) bug: https://github.com/vim/vim/issues/4738
if has('macunix')
  function! OpenURLUnderCursor()
    let s:uri = matchstr(getline('.'), '[a-z]*:\/\/[^ >,;()"]*')
    let s:uri = shellescape(s:uri, 1)
    if s:uri != ''
      silent exec "!open '".s:uri."'"
      :redraw!
    endif
  endfunction
  nnoremap gx :call OpenURLUnderCursor()<CR>
endif

" Open url under cursor
function! OpenURLUnderCursor()
  let s:uri = expand('<cWORD>')
  let s:uri = substitute(s:uri, '?', '\\?', '')
  let s:uri = shellescape(s:uri, 1)
  if s:uri != ''
    silent exec "!firefox '".s:uri."'"
    :redraw!
  endif
endfunction
nnoremap gx :call OpenURLUnderCursor()<CR>


" Leader 
let mapleader = " "

" /*** vifm config ***/

" let g:vifm_replace_netrw = 1
let g:vifm_replace_netrw_cmd = "SplitVifm"
let g:vifm_embed_split = 1
" let g:vifm_embed_term = 1
" Do not load netrw plugin
let g:loaded_netrw = 1
let g:loaded_netrwPlugin = 1
nnoremap <leader>s :SplitVifm<CR>
nnoremap <leader>v :VsplitVifm<CR>
nnoremap <leader>d :DiffVifm<CR>

"diffs
nnoremap <leader>p :diffput<CR>
nnoremap <leader>g :diffget<CR>

"repeat F T movements 
nnoremap <leader>, ,
nnoremap , ;

"Command line map
nnoremap ; :


" Go to file make gf as go to file with line number instead of gF
nnoremap gf gF
nnoremap <c-w>f <c-w>F

" Open non existing file under the curosor 
:noremap <leader>gf :e <cfile><cr>

" set working folder to the file under the cursor
command! Cdf :cd %:h

" If I forgot to sudo a file, do that with :w!!
cmap w!! %!sudo tee > /dev/null %
command! SudoW exec 'w !sudo tee %'

" file types

exec 'au FileType tex so '.$VIMFolder.'bundle/ftplugin/tex_latexSuite.vim'


" autocomplete sortcut
inoremap <C-Space> <C-x><C-o>
inoremap <C-]> <C-x><C-]>

 "Window faster moves
 nnoremap <C-j> <C-w><C-j>
 map <C-k> <C-w><C-k>
 map <C-h> <C-w><C-h>
 map <C-l> <C-w><C-l>

" Close tab
noremap <leader>tc :tabclose

 " set terminal to interactive
set shellcmdflag=-ic


" VIM Shell
" set shell=/bin/zsh

" VIM Terminal - only on vim (not nvim, nvim uses server client as commands)
" Function to call from the the terminal in order to change working dir
" arglist : [ cwd ]
" change window local working directory

function! Tapi_lcd(bufnum, arglist)
	let winid = bufwinid(a:bufnum)
	let cwd = get(a:arglist, 0, '''')
	if winid == -1 || empty(cwd)
		return
	endif
	exec 'cd ' . cwd
endfunction

function! Tapi_sp(bufnum, arglist)
	let winid = bufwinid(a:bufnum)
	let path = get(a:arglist, 0, '''')
	if winid == -1 || empty(path)
		return
	endif
	exec 'sp ' . path
endfunction

command! -nargs=* Tt :term <args>
nmap <silent> <leader>t :sp \| term<CR>
tnoremap <C-w>; <C-w>:
"window movement
tnoremap <C-j> <C-w><C-j>
tnoremap <C-k> <C-w><C-k>
tnoremap <C-h> <C-w><C-h>
tnoremap <C-l> <C-w><C-l>

" Vim Windows resize
nnoremap <silent> <Leader>- :exe "resize " . (winheight(0) * 2/3)<CR>
nnoremap <silent> <Leader>= :exe "resize " . (winheight(0) * 3/2)<CR>
nnoremap <silent> <Leader>0 :exe "vertical resize " . (winwidth(0) * 3/2)<CR>
nnoremap <silent> <Leader>9 :exe "vertical resize " . (winwidth(0) * 2/3)<CR>

"Command with copy to clipboard
command! -nargs=* CWithCopy exec "redir @* | <args> | redir END"

"VimGrep command
"

command! -nargs=* VGrep execute 'vimgrep /'.<f-args>.'/ **/*.*'
command! -nargs=* VGrepCWFileExt execute 'vimgrep // **/*.'.<f-args>
command! -nargs=1 CfdoReplace  execute 'cfdo %s//'.<f-args>.'/gc | update'


