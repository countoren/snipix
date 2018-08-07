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
    bashrc = 
    let dfUtils = import ./HomeInstall/dotfilesUtils.nix  
      { mkDerivation = stdenv.mkDerivation; writeText = pkgs.writeText; };
    in
    (dfUtils.toDotfileWithDeps ./bash-config/bashrc {inherit ovim;});

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
        omvim
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
  };
}
