{ config, pkgs, ... }:
{

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
       experimental-features = nix-command flakes
    '';
  };
  # Set your time zone.
  time.timeZone = "US/East-Indiana";
  services.xserver.xkbOptions = "ctrl:swapcaps";
  console.font =
    "${pkgs.terminus_font}/share/consolefonts/ter-u28n.psf.gz";
  services.xserver.dpi = 160;
  environment.variables = {
    GDK_SCALE = "0.75";
    GDK_DPI_SCALE = "1.25";
    _JAVA_OPTIONS = "-Dsun.java2d.uiScale=0.75";
    QEMU_OPTS = "-m 4096 -smp 4 -enable-kvm";
  };
  services.qemuGuest.enable = true;
  programs.zsh.enable = true;


  users.defaultUserShell = pkgs.zsh;

  environment.systemPackages = with pkgs; [
    vifm
    fzf
    git
    xclip
    nixos-generators
    #needs unsafe python
    #nixops
    traceroute
  ];
}