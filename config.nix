{
  # Allow proprietary packages
	allowUnfree = true;
  allowBroken = false;

  packageOverrides = pkgs: with pkgs; rec {

    dotfiles = buildEnv {
      name = "dotfiles";
      paths =       
      let dfUtils = import ./HomeInstall/dotfilesUtils.nix  
        { mkDerivation = stdenv.mkDerivation; writeText = pkgs.writeText; };
      in
      [
        (dfUtils.toDotfileWithDeps ./bash-config/bashrc {inherit stdenv ovim;})
        (dfUtils.toDotfile ./HomeInstall/bash_profile)
      ];
    };

    homeInstall = pkgs.writeShellScriptBin "homeInstall" (builtins.readFile ./HomeInstall/homeInstallSymLinks);

    startApps = pkgs.writeShellScriptBin "startStatusMenuApps" ''
      for filename in $HOME/.nix-profile/StatusMenu/*.app; do
        open "$filename"
      done
    '';

    core = buildEnv {
      name = "core";
      paths = [  
        #my tools
        homeInstall

        #core packages
        git
        ovim
      ];
    };

    macCore = buildEnv {
      name = "mac-core";
      paths = [  
        core

        #my tools
        startApps
	
        #mac core packages
        omvim

        #status menu Apps
        spectacle
        scrollReveser
      ];
    };

    myvimrc = import ./vim/VimrcAndPlugins.nix { inherit pkgs; };

    tvim = import ./vim/minimalVim.nix { inherit pkgs; };
    ovim = import ./vim { inherit pkgs; name = "ovim"; vimrcDrv = myvimrc; };

    omvim = with pkgs; with stdenv; import ./vim/macvim.nix { 
      inherit mkDerivation fetchFromGitHub writeShellScriptBin; 
      name = "omvim";
      vimrcDrv = myvimrc;
    };

    spectacle = stdenv.mkDerivation {
      name = "spectacle";
      src = fetchurl { 
        url = "https://s3.amazonaws.com/spectacle/downloads/Spectacle+1.2.zip"; 
        sha256="037kayakprzvs27b50r260lwh2r9479f2pd221qmdv04nkrmnvbn"; 
      };
      buildInputs = [ unzip ];
      buildCommand = ''
        mkdir -p $out/StatusMenu
        unzip $src -d $out/StatusMenu
      '';
    };

    scrollReveser = stdenv.mkDerivation {
      name = "scrollReveser";
      src = fetchurl { 
        url = "https://pilotmoon.com/downloads/ScrollReverser-1.7.6.zip"; 
        sha256="1f6lmw121gnvysxq4j1k1idx83dyychlxzacpwn2s5bhjh467x8d"; 
      };
      buildInputs = [ unzip ];
      buildCommand = ''
        mkdir -p $out/StatusMenu
        unzip $src -d $out/StatusMenu
      '';
    };

    my_vb = stdenv.mkDerivation {
      name = "my_vb";
      src = fetchurl { 
        url = "https://download.virtualbox.org/virtualbox/5.2.18/VirtualBox-5.2.18-124319-OSX.dmg"; 
        sha256="0xw38yandhc3sazq8dzfq1x8dr7b94fzqlinmsfl01k0nxx5dbw9"; 
      };
      buildInputs = [ p7zip ];
      buildCommand = ''
        7z x $src
        cd VirtualBox
        mkdir -p $out/Applications
        cp -rfv MacVim.app $out/Applications
        unzip $src -d $out/Applications
      '';
    };
  };
}
