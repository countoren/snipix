{
# Allow proprietary packages
	allowUnfree = true;
  allowBroken = true;

  packageOverrides = pkgs: with pkgs; rec {

    homeInstall = pkgs.writeShellScriptBin "homeInstall" (builtins.readFile ./HomeInstall/homeInstallSymLinks);

    dotfiles = buildEnv {
      name = "dotfiles";
      paths =       
      let dfUtils = import ./HomeInstall/dotfilesUtils.nix  
        { mkDerivation = stdenv.mkDerivation; writeText = pkgs.writeText; };
      in
      [
        (dfUtils.toDotfileWithDeps ./bash-config/bashrc {inherit ovim;})
        (dfUtils.toDotfile ./HomeInstall/bash_profile)
      ];
    };

    core = buildEnv {
      name = "core";
      paths = [  
        dotfiles
        ovim
      ];
    };

    vimrc = import ./vim/VimrcAndPlugins.nix { inherit pkgs; };
    ovim = import ./vim/default.nix { inherit pkgs; };

    mvim_pure = with pkgs; with stdenv; import ./vim/macvim.nix { inherit mkDerivation fetchFromGitHub; };

    #macvim = pkgs.writeShellScriptBin "macvim" ''${mvim_pure}/bin/mvim -u ${vimrc}'';
  };
}
