{ pkgs ? import <nixpkgs>{}
, name ? "omvim"
, nameterminal ? "omshell"
, vimrcAndPlugins ? import ./VimrcAndPlugins.nix {}
}:
with pkgs;
let macvim = stdenv.mkDerivation {
  name = "macvim";
  src = fetchurl { 
    url = "https://github.com/macvim-dev/macvim/releases/download/snapshot-159/MacVim.dmg"; 
    sha256="1j07j0pw3c1ff3b1825lzacf809jjr3ilaf0i3xnvxynqxk9r7ig"; 
  };
  buildInputs = [ undmg ];
  buildCommand = ''
    undmg < $src

    mkdir -p $out/Applications
    cp -rfv MacVim.app $out/Applications

    ln -sf ${vimrcAndPlugins} $out/Applications/MacVim.app/Contents/Resources/vim/vimrc
    ln -sf ${vimrcAndPlugins} $out/Applications/MacVim.app/Contents/Resources/vim/gvimrc
  '';

};
in buildEnv
{
  name = "omvim";
  paths = [
    (writeShellScriptBin name '' ${macvim}/Applications/MacVim.app/Contents/bin/mvim "$@" '')
    (writeShellScriptBin nameterminal '' ${macvim}/Applications/MacVim.app/Contents/bin/mvim . -c 'term ++curwin' "$@" '')

  ];

} 
