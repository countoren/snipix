{ pkgs ? import <nixpkgs> {}
, pkgsPath ? toString (import ../pkgsPath.nix)
, additionalVimrc?  ''
set guifont=DejaVu\ Sans\ Mono:h15
set lazyredraw
set title
augroup dirchange
    autocmd!
    autocmd DirChanged * let &titlestring=v:event['cwd']
augroup END

tnoremap <c-h> <c-\><c-n><c-w>h
tnoremap <c-j> <c-\><c-n><c-w>j
tnoremap <c-k> <c-\><c-n><c-w>k
tnoremap <c-l> <c-\><c-n><c-w>l
tnoremap <a-;> <c-\><c-n>:

''
, nvim ? import ./nvim.nix { inherit pkgs pkgsPath additionalVimrc;} 
}:
/*
let 
desktopItem =
pkgs.makeDesktopItem { name = "GNvim"; exec = "gnvim"; icon = "gnvim"; desktopName = "GNvim"; genericName = "sdfsdfsdfsdf"; categories = ["Utility" "Engineering"]; };
in
pkgs.writeShellApplication {
  name = "gnv";
  runtimeInputs = [ pkgs.gnvim nvim ];
  text = ''
    gnvim --nvim ${nvim}
  '';
}
  */
pkgs.symlinkJoin {
  name = "gnvim";
  paths = [
    pkgs.gnvim
    nvim
  ];
  buildInputs = [ pkgs.makeWrapper ];
  postBuild = ''
    wrapProgram $out/bin/gnvim \
      --add-flags "--nvim $out/bin/nvim"
  '';
  } 