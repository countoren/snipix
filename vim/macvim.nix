{ mkDerivation, fetchFromGitHub, writeShellScriptBin, name, vimrcDrv }:
let mvimDrv = 
  mkDerivation {
        name = "macvim-8.0.127-python-countoren";
        src = fetchFromGitHub {
          owner = "countoren";
          repo = "Macvim-8.0.127-python";
          rev = "c81e676a6b2dc08c736a25bf4b3260573ce68dc4";
          sha256 = "1cpsy2na3lfg2mh0h3z4zp7ldn8rrwycvrb9mzw4vhvif636g2rk";
        };
        buildCommand = ''
          mkdir -p $out/Applications
          cp -rfv $src/MacVim.app $out/Applications
          chmod 755 $out/Applications/MacVim.app/Contents/MacOS/* \
                    $out/Applications/MacVim.app/Contents/bin/*
          mkdir -p $out/bin
          ln -sf $out/Applications/MacVim.app/Contents/bin/mvim $out/bin/mvim
          ln -sf $out/bin/mvim $out/bin/vim
          ln -sf $out/bin/mvim $out/bin/vi
          ln -sf $out/bin/mvim $out/bin/gvim
        '';
  };
in
  writeShellScriptBin name ''${mvimDrv}/bin/mvim -u ${vimrcDrv} "$@"''
