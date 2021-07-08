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

    templatesEnv = pkgsPath : import ~/Desktop/templatesEnv 
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
        (import ./nixUtils {})
        nixops
        cachix
        #git
        (import ./git {})



        #Signal env
        signalTools
        #TODO: use custom pass with password-store setup
        # password-store for now is in dropbox
        # synlink to use and import gpg key
        pass
        #if warning like :
        # gpg: WARNING: server 'gpg-agent' is older than us (2.2.20 < 2.2.21)
        # gpg: decryption failed: No secret key
        # could restart gpg server with:
        # gpgconf --kill all
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

        raspTools

        #TopManage
        (lib.attrValues (import ./topmanage/ssh.nix { inherit pkgs;}))

        #my tools
        homeInstall
        ducks #show folder's space usage du -cks

        #core packages
        git
        ( ovim { inherit pkgsPath; } )
        #git my utils
        gpushAll
        gupdateforked

        #vim-like file manager
        vifm

        #nix version of:
        bash
        zsh


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

        #Browsers

        #Does not work
        # error: only HFS file systems are supported.
        # (mkDarwinApp {
        #   name = "TOR";
        #   url = "https://www.torproject.org/dist/torbrowser/10.0.12/TorBrowser-10.0.12-osx64_en-US.dmg";
        #   sha256="0wf8pbasmy2qj4pf4ff09750qy9yqz210v2g48mbg4hz5bx1l959"; 
        # })
        #video players
        (mkDarwinApp {
          name = "VLC";
          url = "https://ftp.osuosl.org/pub/videolan/vlc/3.0.12/macosx/vlc-3.0.12-intel64.dmg"; 
          sha256="1lg5kd2b55072lnpq4k1f74cixqp2i6g63b883l4hx0dxrw5m2wv"; 
        })

        #Chat Apps

        # Hangs on downloading...
        # (mkDarwinApp { 
        #   url = "https://download.delta.chat/desktop/v1.14.1/DeltaChat-1.14.1.dmg";
        # })

        #status menu Apps
        spectacle

        vpnutil

        #keyboard Shortcuts
        #might need a restart and reload of the daemon in order that the skhd dotfile will take effect
        skhd
        (pkgs.writeShellScriptBin "keyboard-skhd-load-agent" ''
          launchctl load ${skhd}/Library/LaunchDaemons/org.nixos.skhd.plist
        '')
        (pkgs.writeShellScriptBin "keyboard-skhd-remove-agent" ''
          launchctl remove ${skhd}/Library/LaunchDaemons/org.nixos.skhd.plist
        '')
        (pkgs.writeShellScriptBin "keyboard-skhd-reload-agent" ''
          keyboard-skhd-remove-agent && keyboard-skhd-load-agent
        '')
      ];
    };

    macHome =  { pkgsPath ? "~/Dropbox/nixpkgs" } : (buildEnv {
      name = "mac-home";
      paths = [  
        ( macCore { inherit pkgsPath; })
        #home packages
        # not needed with magic mouse.
        # scrollReveser
      ];
    });

    



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
        (dfUtils.toDotfileWithDeps ./dotfiles/zshrc { inherit pkgs; })
        (dfUtils.toDotfile ./dotfiles/skhdrc)
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

    fsvim = import ./vim/fsvim.nix { pkgsPath = "~/Dropbox/nixpkgs"; };


    vscode-addPersonalConfig =  import ./vscode;
    myVSCodeConfig = vscode-addPersonalConfig {};

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
        undmg "$src"

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




    sourcetree = 
    let app =
      stdenv.mkDerivation rec {
        name = "sourcetree-${version}";
        version = "4.0.1_234";
        src = fetchurl { 
          url = "https://product-downloads.atlassian.com/software/sourcetree/ga/Sourcetree_${version}.zip";
          sha256="0c9ikh4s453qbiqfw6zxzqi6xbn8g6fw1nj4djzjj5y9s6v5kc5n"; 
        };
        buildInputs = [ unzip ];
        buildCommand = ''
          mkdir -p $out/Applications
          unzip $src -d $out/Applications
       '';
      };
    in pkgs.writeShellScriptBin "stree" ''open -a "${app}/Applications/SourceTree.App" "$@"'';


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

    #Signal signal-cli

    # phoneNumber = 111111111;
    #signalTools = with pkgs; buildEnv {
    #    name = "sms-tools";
    #    paths = 
    #    [
    #      signal-cli
    #      (writeShellScriptBin "sms-register" ''signal-cli -u ${phoneNumber} register '')
    #      #should take the output of register in order to verify
    #      (writeShellScriptBin "sms-verify" '' signal-cli -u ${phoneNumber} verify $1 '')
    #      (writeShellScriptBin "sms-msg" '' 
    #        signal-cli -u ${phoneNumber} send -m "$2" $1
    #      '')
    #      (writeShellScriptBin "sms-msg-moises" '' 
    #        signal-cli -u ${phoneNumber} send -m "$1" +50768613634
    #      '')
    #    ];
    #  };



    #PI - home
    piHome = writeShellScriptBin "piHome" ''ssh pi@192.168.0.107'';
    
    #TopManage
    tmpkgs = import ./topmanage/tmpkgs.nix;

    
    #VPN
    vpnutil = stdenv.mkDerivation {
      name = "vpnutil";
      src = fetchzip { 
            url = "https://blog.timac.org/2018/0719-vpnstatus/vpnutil.zip";
            sha256 = "0467c66c0h1v7zix8g6dbdgi0gw8c8n6ljmxx24ibxlb4i6bznbf";
          };
      installPhase = ''
        mkdir -p $out/bin
        cp -v vpnutil $out/bin/vpnutil
        '';
      meta = {
        homepage = "https://blog.timac.org/2018/0719-vpnstatus/";
        description = ''Command line tool similar to scutil that can start and stop a VPN service from the Terminal. It also works with IKEv2 VPN services, something not supported by the built-in scutil'';
        license = lib.licenses.mit;
        platforms = ["x86_64-darwin"];
      };
    };


    #Rasberry PI
    raspTools = buildEnv {
      name = "raspi-tools";
      paths = 
      [
        #to unpack arm64 images from hydra
        zstd

        (pkgs.writeShellScriptBin "raspi-mount" '' 
          echo 'NIX refs : https://nixos.wiki/wiki/NixOS_on_ARM#NixOS_installation_.26_configuration'
          echo 'Ras p refs: https://www.raspberrypi.org/documentation/installation/installing-images/mac.md'
          sudo dd if=$1 of=$2 
        '')
      ];
    };
    #Utils


    ducks = pkgs.writeShellScriptBin "ducks" '' du -cks * |sort -rn |head -11 '';
    hgrep = pkgs.writeShellScriptBin "hgrep" ''
    HISTFILE=~/.bash_history
      set -o history
      history | grep $@
    '';

    gpushAll = pkgs.writeShellScriptBin "gpushAll" ''git add -A; git commit -m "$@"; git push'';
    gupdateforked = pkgs.writeShellScriptBin "gupdateforked" ''git fetch upstream && git rebase upstream/master && git push origin master $@'';


    #Utils Functions
    mkDarwinApp = import ./mkDarwinApp.nix {};
    
    
  };
}
