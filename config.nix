let 
ps1904 = import ./nixpkgs1904.nix;
in
{
  # Allow proprietary packages
	allowUnfree = true;
  allowBroken = false;

  packageOverrides = pkgs: with pkgs; rec {
    core = buildEnv {
      name = "core";
      paths = [  
        #nix
        ps1904.nixops

        #my tools
        homeInstall
        ducks #show folder's space usage du -cks

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
        startStatusMenuApps
	
        #mac core packages
        omvim
        sourcetree

        #status menu Apps
        spectacle
      ];
    };

    macHome = buildEnv {
      name = "mac-home";
      paths = [  
        macCore
        #home packages
        scrollReveser
      ];
    };

    nixosVM = ''
    qemu-system-x86_64 -smp 4 -m 8G -net nic -net user,hostname=oren -drive format=raw,file=nixos-graphical-18.03.133114.a4e068ff9c8-x86_64-linux.iso 
     '' ;

    dotfiles = buildEnv {
      name = "dotfiles";
      paths =       
      let dfUtils = import ./HomeInstall/dotfilesUtils.nix  
        { mkDerivation = stdenv.mkDerivation; writeText = pkgs.writeText; };
      in
      [
        (dfUtils.toDotfileWithDeps ./dotfiles/bashrc {inherit stdenv ovim;})
        (dfUtils.toDotfileWithDeps ./dotfiles/profile {inherit stdenv ovim;})
        (dfUtils.toDotfile ./dotfiles/bash_profile)
      ];
    };

    #contains nix-env -i dotfiles
    homeInstall = pkgs.writeShellScriptBin "homeInstall" (builtins.readFile ./HomeInstall/homeInstallSymLinks);


    startStatusMenuApps = pkgs.writeShellScriptBin "startStatusMenuApps" ''
      for filename in $HOME/.nix-profile/StatusMenu/*.app; do
        open "$filename"
      done
    '';


    myvimrc = import ./vim/VimrcAndPlugins.nix { inherit pkgs; };

    tvim = import ./vim/minimalVim.nix { inherit pkgs; };
    ovim = import ./vim { inherit pkgs; name = "ovim"; vimrcDrv = myvimrc; };

    omvim = import ./vim/buildMVim.nix { name = "omvim"; };    


    buildVSCode = (callPackage ./vscode) { inherit lib; };

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

  sourcetree = 
  let app =
    stdenv.mkDerivation rec {
      name = "sourcetree-${version}";
      version = "2.7.3";
      src = fetchurl { 
        url = "https://downloads.atlassian.com/software/sourcetree/Sourcetree_${version}a.zip?_ga=2.247266564.1694723893.1537054121-1133708473.1537054121";
        sha256="0mm3076phha6bnryb7q01548fqwxrf9y996qmanycdv15dbkr372"; 
      };
      buildInputs = [ unzip ];
      buildCommand = ''
        mkdir -p $out/Applications
        unzip $src -d $out/Applications
     '';
    };
  in pkgs.writeShellScriptBin "sourcetree" '' open "${app}/Applications/SourceTree.App" '';


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


    #Utils
    ducks = pkgs.writeShellScriptBin "ducks" '' du -cks * |sort -rn |head -11 '';

    gpushAll = pkgs.writeShellScriptBin "gpushAll" ''git add -A; git commit -m "$@"; git push'';
    
  };
}
