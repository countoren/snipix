{
  # Allow proprietary packages
	allowUnfree = true;
  allowBroken = false;

  packageOverrides = pkgs: with pkgs; rec {

    # my fork of nixpkgs
    # mynixpkgs = import ~/Desktop/nixpkgs-1 {};
    # mynixpkgs = import (fetchFromGitHub {
    #   owner="countoren";
    #   repo="nixpkgs-1";
    #   rev="db41faa13ce7343f78e9f7ed6d01cfab903f8f81";
    #   sha256="0qwqqqlkslminnnq1cx5amxqh34arg67wqdck5zyv7qzyq9vbfjc";
    # }) {};

    templatesEnv = pkgsPath : import ~/Desktop/githubTemplate2nix 
    # templatesEnv = pkgsPath : import (fetchFromGitHub {
    #   owner="countoren";
    #   repo="templatesEnv";
    #   rev="66eb5c1c8dd68276d8ae1af246bdcda0a5daeba0";
    #   sha256="04nllgwp6cz6mdy3ladcwj88vh72wi5ws8csppg4hjjnp2f6064q";
    # }) 
    { githubToken = "d6e87c8a174afca0177f542cf89c100177c19a4c"; templatesFile = "${pkgsPath}/templates.nix"; };
    templates = import ./templates.nix;

    core =  { pkgsPath ? "~/.nixpkgs" } : buildEnv {
      name = "core";
      paths = [  
        #templating tool
        (templatesEnv pkgsPath)
        #nix
        nrepl
        (import ./nixUtils {})
        nixops

        #git
        (import ./git {})

        #TODO: use custom pass with password-store setup
        # password-store for now is in dropbox
        # synlink to use and import gpg key
        pass
        #to export key:
        #gpg --export > pub.key
        #gpg --export-secret-keys > prv.key
        #import:
        #gpg --import pub.key
        #gpg --import prv.key : returns output of the keyid
        #
        #to make trusted:
        #expect -c "spawn gpg --edit-key {keyid} trust quit; send \"5\ry\r\"; expect eof"
        gnupg

        #TopManage
        tmssh-mac-oren
        tmsshBambooLinuxAgent

        #my tools
        homeInstall
        ducks #show folder's space usage du -cks

        #core packages
        git
        ( ovim { inherit pkgsPath; } )
        #git my utils
        gpushAll
        gupdateforked


      ];
    };


    macCore = { pkgsPath ? "~/Dropbox/nixpkgs" } : buildEnv {
      name = "mac-core";
      paths = [  
        ( core { inherit pkgsPath; } )

        #my tools
        startStatusMenuApps
	
        #mac core packages
        (omvim { inherit pkgsPath; })
        sourcetree

        #status menu Apps
        spectacle
      ];
    };

    macHome =  { pkgsPath ? "~/Dropbox/nixpkgs" } : (buildEnv {
      name = "mac-home";
      paths = [  
        ( macCore { inherit pkgsPath; })
        #home packages
        scrollReveser
      ];
    });

    


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
        (dfUtils.toDotfile ./dotfiles/bashrc)
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


    # myvimrc = import ./vim/VimrcAndPlugins.nix { };

    # tvim = import ./vim/minimalVim.nix { inherit vimConfigurableFile; pkgs = ps1803; };

    ovim = { pkgsPath ? "~/.nixpkgs" }:
      import ./vim { vimrcWithPlugins = import ./vim/VimrcAndPlugins.nix { inherit pkgsPath; };};

    omvim = { pkgsPath ? "~/Dropbox/nixpkgs" }:
      import ./vim/macvim.nix { vimrcAndPlugins = import ./vim/VimrcAndPlugins.nix { inherit pkgsPath; };};    


    vscodeEnv =  callPackage (import ./vscode) {};

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


    #tools
    dbeaver = let drv = stdenv.mkDerivation {
      name = "dbeaver";
      src = fetchurl { 
        url = "https://dbeaver.io/files/dbeaver-ce-latest-macos.dmg"; 
        sha256="1xsk795d06v7jnrvqwx6bnw77fml14wlcpv1x8cqg89v1qn9c01z"; 
      };
      buildInputs = [ undmg ];
      buildCommand = ''
        undmg < $src

        mkdir -p $out/Applications
        cp -rfv DBeaver.app $out/Applications
      '';
    };
    in 
    buildEnv {
      name = "dbeaver";
      paths = 
      [
        drv
        (writeShellScriptBin "dbeaver" ''
          open ${drv}/Applications/DBeaver.app
        '')
      ];
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

    tmssh-mac-oren = pkgs.writeShellScriptBin "tmssh-mac-oren" "${sshpass}/bin/sshpass -f <(pass topmanage/ssh/macOren) ssh orenrozen@172.16.10.110";
    tmsshBambooLinuxAgentOld = pkgs.writeShellScriptBin "tmsshBambooLinuxAgentOld" "sshpass -f <(pass topmanage/ssh/bambooLinuxAgent) ssh orenrozen@172.16.31.38";

    tmsshBambooLinuxAgent = pkgs.writeShellScriptBin "tmsshBambooLinuxAgent" "ssh orenrozen@172.16.31.46";

    tmsshBambooLinuxAgentAsBambooUser = pkgs.writeShellScriptBin "tmsshBambooLinuxAgentAsBambooUser" "ssh -t orenrozen@172.16.31.46 'sudo su -l bambooagent'";

    tmpkgs = import ( fetchTarball  "https://code.topmanage.com/rest/api/latest/projects/DEVUTILS/repos/tmpkgs/archive?format=tgz&prefix=tmpkgs" ) {}; 

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
