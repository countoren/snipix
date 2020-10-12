{ pkgs ? import <nixpkgs>{}
, name ? "omvim"
, nameterminal ? "omshell"
, vimrcAndPlugins ? import ./VimrcAndPlugins.nix {}
}:
with pkgs;
let macvim = stdenv.mkDerivation {
  name = "macvim";
  src = fetchurl { 
    url = "https://github.com/macvim-dev/macvim/releases/download/snapshot-163/MacVim.dmg"; 
    sha256="0dysy5nmn63cmr5kahij0657si49cfq6kylgnai2zd8995q7mc2s"; 
  };
  buildInputs = [ undmg ];
  buildCommand = ''
    undmg "$src"

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
    macvim
    #this function will trigger vimrc sp function in order to split window when used terminal from vim
    (writeShellScriptBin "sp" ''
      printf '\033]51;["call", "Tapi_sp", ["%s"]]\007' `${coreutils}/bin/realpath $1`
    '')
    #this function will set working dir to terminal's pwd used terminal from vim
    (writeShellScriptBin "cdv" ''
      printf '\033]51;["call", "Tapi_lcd", ["%s"]]\007' "$(pwd)"
    '')
    (writeShellScriptBin name '' ${macvim}/Applications/MacVim.app/Contents/bin/mvim "$@" '')
    (writeShellScriptBin nameterminal '' ${macvim}/Applications/MacVim.app/Contents/bin/mvim . -c 'term ++curwin' "$@" '')

  ];

} 
