{
# Allow proprietary packages
	allowUnfree = true;
  allowBroken = false;

  packageOverrides = pkgs: with pkgs; rec {

    test = pkgs.writeShellScriptBin "test" ''
    if [ -f "$HOME/Dropbox/nixpkgs/config.nix" ]; then
      mkdir -p ~/mybla
      echo "import ~/Dropbox2/nixpkgs/config.nix" > ~/mybla/file
    fi
      '';



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

    startApps = pkgs.writeShellScriptBin "startApps" ''
      open $HOME/.nix-profile/Applications/Spectacle.app
    '';

    core = buildEnv {
      name = "core";
      paths = [  
        homeInstall

        git
        ovim
      ];
    };

    macCore = buildEnv {
      name = "mac-core";
      paths = [  
        core

        startApps
        omvim
        spectacle
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
        mkdir -p $out/Applications
        unzip $src -d $out/Applications
      '';
    };


  };
}
