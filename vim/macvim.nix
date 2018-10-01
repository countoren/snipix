{ mkDerivation, fetchFromGitHub, makeWrapper, name, vimrcDrv }:
  mkDerivation {
        name = name;
        src = fetchFromGitHub {
          owner = "countoren";
          repo = "Macvim-8.0.127-python";
          rev = "c81e676a6b2dc08c736a25bf4b3260573ce68dc4";
          sha256 = "1cpsy2na3lfg2mh0h3z4zp7ldn8rrwycvrb9mzw4vhvif636g2rk";
        };
	buildInputs = [ makeWrapper ];
        installPhase = ''
	  mkdir -p $out/Applications
          cp -rfv $src/MacVim.app $out/Applications
          chmod 755 $out/Applications/MacVim.app/Contents/MacOS/* \
                    $out/Applications/MacVim.app/Contents/bin/*
                    
          chmod 755 $out/Applications/MacVim.app/Contents/bin

          wrapProgram $out/Applications/MacVim.app/Contents/bin/mvim --add-flags '-u ${vimrcDrv} "$@"'
          mkdir -p $out/bin
          ln -sf $out/Applications/MacVim.app/Contents/bin/mvim $out/bin/mvim
          ln -sf $out/bin/mvim $out/bin/vim
          ln -sf $out/bin/mvim $out/bin/vi
          ln -sf $out/bin/mvim $out/bin/gvim

        '';
  }
