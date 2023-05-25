{ config, pkgs, ... }:
{
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.p1n3 = {
    isNormalUser = true;
    initialPassword = "p@ssw0rd";
    extraGroups = [ "wheel" "adbusers"]; # Enable ‘sudo’ for the user.
  };

  environment.systemPackages = with pkgs; [

    gnomeExtensions.always-show-titles-in-overview

    protonvpn-gui
    protonvpn-cli
    firefox
    discord
    brave
    bitwarden
    signal-desktop
    element-desktop
    bitwarden-cli
    # PDF tools
    zathura
    pdfsandwich

    # Security tools
    wifite2
    iw
    macchanger
    john
  ];

  networking.hostName = "p1n3"; # Define your hostname.
  # networking.defaultGateway = "192.168.1.1";
  # networking.nameservers = [ "8.8.8.8" ];
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # bigger tty fonts
  console.font =
    "${pkgs.terminus_font}/share/consolefonts/ter-u28n.psf.gz";

  console.useXkbConfig = true;


  services.xserver.xkbOptions = "ctrl:swapcaps";
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];


  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };



  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;
  services.xserver.libinput.touchpad.naturalScrolling = true;
  services.xserver.libinput.touchpad.tappingDragLock = true;
  services.xserver.libinput.touchpad.disableWhileTyping = true;
  services.xserver.libinput.touchpad.accelSpeed = "1.27";

}
