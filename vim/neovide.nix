{ pkgs ? (builtins.getFlake (toString ../.)).inputs.nixpkgs.legacyPackages.${builtins.currentSystem}
, pkgsPath ? toString (import ../pkgsPath.nix)
, additionalVimrc?  ''
set guifont=DejaVu\ Sans\ Mono:h15
let g:neovide_remember_window_size = v:true
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
pkgs.symlinkJoin {
  name = "onvide";
  paths = [
    #override .desktop to add terminal property
    /*
    ( pkgs.concatTextFile rec {
      name = "neovide.desktop";
      destination = "/share/applications/${name}";
      files = [ 
        (pkgs.neovide + destination)
        (pkgs.writeText "additionalDesktop" '' Terminal=false '')
      ];
    })
    */
    pkgs.neovide
    nvim
  ];
  buildInputs = [ pkgs.makeWrapper ];
  postBuild = ''
    wrapProgram $out/bin/neovide \
      --add-flags "--maximized"
  '';
  /*
  postBuild = ''
    ln -sf $out/share/icons/hicolor/* $out/share/icons
  '';
  postBuild = ''
    wrapProgram $out/bin/neovide \
      --add-flags "-- --listen ~/.cache/nvim/server.pipe"
  '';
  */
  } 
/*
pkgs.neovide.overrideAttrs (old: {
  postInstall = ''
    grep -qxF 'Terminal=false' assets/neovide.desktop || \
    echo 'Terminal=false' >> assets/neovide.desktop    
  ''
  + old.postInstall  
  ;
})
let 
desktopItem =
makeDesktopItem { name = "neovide"; exec = "neovide"; icon = "neovide"; desktopName = "NeoVide"; genericName = meta.description; categories = ["Utility" "Engineering"]; }
in
pkgs.writeShellApplication {
  name = "nv";
  runtimeInputs = [ pkgs.neovide nvim ];
  text = ''
    neovide -- --listen ~/.cache/nvim/server.pipe
  '';
}
  pkgs.runCommand "onvide" { buildInputs = [ pkgs.makeWrapper ]; }
''
  cp -r ${pkgs.neovide} $out
  grep -qxF 'Terminal=false' $out/share/applications/neovide.desktop || \
  echo 'Terminal=false' >> $out/share/applications/neovide.desktop
''
  # mkdir $out
  # ln -sf ${pkgs.neovide}/bin $out/bin
  # mkdir $out/share
  # ln -sf ${pkgs.neovide}/share/icons $out/share/icons
  # mkdir $out/share/applications
  */
