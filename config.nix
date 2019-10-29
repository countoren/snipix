{
  # Allow proprietary packages
	allowUnfree = true;
  allowBroken = false;

  packageOverrides = pkgs: with pkgs; rec {
    core = buildEnv {
      name = "core";
      paths = [  
        #nix
        nrepl
        nixops

        #TopManage
        tmsshBambooLinuxAgent

        #my tools
        homeInstall
        ducks #show folder's space usage du -cks


        #core packages
        git
        ovim
        #git my utils
        gpushAll
        gupdateforked

        #pass

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
        (dfUtils.toDotfile ./dotfiles/zshrc)
      ];
    };

    #contains nix-env -i dotfiles
    homeInstall = pkgs.writeShellScriptBin "homeInstall" (builtins.readFile ./HomeInstall/homeInstallSymLinks);


    startStatusMenuApps = pkgs.writeShellScriptBin "startStatusMenuApps" ''
      for filename in $HOME/.nix-profile/StatusMenu/*.app; do
        open "$filename"
      done
    '';


    myvimrc = import ./vim/VimrcAndPlugins.nix { pkgs = ps1803; };

    tvim = import ./vim/minimalVim.nix { inherit vimConfigurableFile; pkgs = ps1803; };
    ovim = import ./vim { };

    omvim = import ./vim/macvim.nix { };    


    buildVSCode = (callPackage ./vscode) { inherit lib; };


    dev = import ./dev { inherit pkgs; };

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



    #clipboard helper app
    clipy = 
      let installer = fetchurl { 
        url = "https://github.com/Clipy/Clipy/releases/download/1.1.2/Clipy_1.1.2.dmg"; 
        sha256="133daq2qyv54canpj5dnd8b21b3a04w7sib11pf5ww73ni5kx191"; 
      };
    in pkgs.writeShellScriptBin "clipy-installer" '' open "${installer}" '';


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

    # pass = import ./pass { inherit pkgs;};


    #PI - home
    piHome = writeShellScriptBin "piHome" ''ssh pi@192.168.0.107'';
    
    #TopManage
    #ssh
    tmsshBambooLinuxAgentOld = pkgs.writeShellScriptBin "tmsshBambooLinuxAgentOld" "sshpass -f <(pass topmanage/ssh/bambooLinuxAgent) ssh orenrozen@172.16.31.38";

    tmsshBambooLinuxAgent = pkgs.writeShellScriptBin "tmsshBambooLinuxAgent" "ssh orenrozen@172.16.31.46";

    tmsshBambooLinuxAgentAsBambooUser = pkgs.writeShellScriptBin "tmsshBambooLinuxAgentAsBambooUser" "ssh -t orenrozen@172.16.31.46 'sudo su -l bambooagent'";

    #Utils

    nrepl = pkgs.writeShellScriptBin "nrepl" "nix repl '<nixpkgs>'";
    ducks = pkgs.writeShellScriptBin "ducks" '' du -cks * |sort -rn |head -11 '';
    hgrep = pkgs.writeShellScriptBin "hgrep" ''
    HISTFILE=~/.bash_history
      set -o history
      history | grep $@
    '';

    gpushAll = pkgs.writeShellScriptBin "gpushAll" ''git add -A; git commit -m "$@"; git push'';
    gupdateforked = pkgs.writeShellScriptBin "gupdateforked" ''git fetch upstream && git rebase upstream/master && git push origin master $@'';
    
  };
}
