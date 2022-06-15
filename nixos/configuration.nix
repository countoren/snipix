# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{ pkgs ? import <nixpkgs>{}, ... }:
{ config, ... }:
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "p1n3"; # Define your hostname.
  # networking.defaultGateway = "192.168.1.1";
  # networking.nameservers = [ "8.8.8.8" ];
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Set your time zone.
  time.timeZone = "EST";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.wlp0s20f3.useDHCP = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  # };

  # Enable the X11 windowing system.
  services.xserver.enable = true;


  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;


  # Configure keymap in X11
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";
   
  console.useXkbConfig = true;
  services.xserver.xkbOptions = "ctrl:swapcaps";

  
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];


  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  # hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;
  services.xserver.libinput.touchpad.naturalScrolling = true;
  services.xserver.libinput.touchpad.tappingDragLock = true;
  services.xserver.libinput.touchpad.disableWhileTyping = true;
  services.xserver.libinput.touchpad.accelSpeed = "1.27";

   # bigger tty fonts
  console.font =
    "${pkgs.terminus_font}/share/consolefonts/ter-u28n.psf.gz";

  #160
  services.xserver.dpi = 160;
  environment.variables = {
    GDK_SCALE = "0.75";
    GDK_DPI_SCALE = "1.25";
    _JAVA_OPTIONS = "-Dsun.java2d.uiScale=0.75";
  };


  services.xserver.monitorSection = ''
    DisplaySize 768.0 432.0
  '';

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.p1n3 = {
    isNormalUser = true;
    initialPassword = "p@ssw0rd";
    extraGroups = [ "wheel" "adbusers"]; # Enable ‘sudo’ for the user.
  };

   programs.adb.enable = true;

   programs.zsh.enable = true;
   users.defaultUserShell = pkgs.zsh;


  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    androidenv.androidPkgs_9_0.platform-tools
    vifm
    fzf
    #NixOS general utils scripts
    (pkgs.writeShellScriptBin "install-system" ''
	nixos-rebuild switch --flake "$@" .#
    '')

    (pkgs.writeShellScriptBin "install-home" ''
	nix build .#homeManagerConfigurations.p1n3.activationPackage && ./result/activate
    '')

    (pkgs.writeShellScriptBin "nfrepl" ''
        echo 'builtins.getFlake (toString ./.)' > repl.nix && nix repl ./repl.nix
    '')
    (pkgs.writeShellScriptBin "nfreplconfig" ''
        echo '(builtins.getFlake (toString ./.)).nixosConfigurations.p1n3.config' > repl.nix && nix repl ./repl.nix
    '')
    (pkgs.writeShellScriptBin "nfreploptions" ''
        echo '(builtins.getFlake (toString ./.)).nixosConfigurations.p1n3.options' > repl.nix && nix repl ./repl.nix
    '')


     (pkgs.writeShellScriptBin "nfreplnixpkgs" ''
         echo 'import (builtins.getFlake (toString ./.)).inputs.nixpkgs { system = builtins.currentSystem; }' > repl.nix && nix repl ./repl.nix
     '')

    (pkgs.writeShellScriptBin "nfupdate" ''
      nix flake lock --update-input $@
    '')
    (pkgs.writeShellScriptBin "nclean" ''
       sudo nix-env -p /nix/var/nix/profiles/system --delete-generations +2
    '')




    #core env
    #((import ./config.nix).packageOverrides { inherit pkgs; }).core

    #core vim
    #(import ./vim/linuxVim.nix { inherit pkgs; })

    #NIXOS specific packages
    git
    protonvpn-gui
    protonvpn-cli
    dig 
    firefox
    torbrowser
    brave
    discord
    xclip
    bitwarden
    signal-desktop
    bitwarden-cli
    nixos-generators
    gparted 
    nixops
    traceroute
  ];

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
       experimental-features = nix-command flakes
    '';
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  #users.users.p1n3.openssh.authorizedKeys.keys = [ "" ];

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?

}

