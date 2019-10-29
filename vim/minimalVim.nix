{ vimConfigurableFile,  pkgs }:
with pkgs; 
let
  my_vim_configurable =
  (vimUtils.makeCustomizable (callPackage vimConfigurableFile {
    inherit (darwin.apple_sdk.frameworks) CoreServices Cocoa Foundation CoreData;
    inherit (darwin) libobjc cf-private;
    lua = pkgs.lua5_1;
    config.vim = {
      lua = false;
      python = false;
      ruby = false;
    };

    features = "tiny"; # one of  tiny, small, normal, big or huge
    gui = "no";
  })).merge {
    postFixup = ''
      rm -r $out/share $out/bin/vimtutor
    '';
  };
in
vimUtils.vimWithRC {
  name = "tvim";
  vimExecutable = "${my_vim_configurable}/bin/vim";
  vimrcFile = vimUtils.vimrcFile {
    customRC = ''
set wildmenu
set ignorecase
set hls
set number
set ruler
set showmatch
set ls=2
set iskeyword+=_,$,@,%,#  
set foldmethod=marker
set backspace=2
set nocompatible

set cf  " Enable error files & error jumping.
set clipboard+=unnamed  " Yanks go on clipboard instead.
set history=256  " Number of things to remember in history.
set autowrite  " Writes on make/shell commands
set timeoutlen=250  " Time to wait after ESC (default causes an annoying delay)

"adding more history (default 20)
set history=1000
	
"Formatting

" set smartindent
set tabstop=2
set softtabstop=2
set shiftwidth=2


"Command line map
nnoremap ; :


" If I forgot to sudo a file, do that with :w!!
cmap w!! %!sudo tee > /dev/null %

" autocomplete sortcut
inoremap <C-Space> <C-x><C-o>
inoremap <C-]> <C-x><C-]>

    '';

  };
}
