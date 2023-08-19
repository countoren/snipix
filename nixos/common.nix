{ nix-alien } :
{ config, pkgs, lib, ... }:
{
  
  environment.etc.nixpkgs.source = pkgs.path;
  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
       experimental-features = nix-command flakes
    '';
  };
  # Set your time zone.
  time.timeZone = pkgs.lib.mkForce "US/East-Indiana";

  # console.useXkbConfig = true;
  # services.xserver.xkbOptions = "ctrl:swapcaps";


  environment.variables = {
    NIX_PATH = lib.mkForce "nixpkgs=/etc/nixpkgs";
    GDK_SCALE = "0.75";
    GDK_DPI_SCALE = "1.25";
    _JAVA_OPTIONS = "-Dsun.java2d.uiScale=0.75";
    QEMU_OPTS = "-m 4096 -smp 4 -enable-kvm";
  };

  services.qemuGuest.enable = true;
  programs.zsh.enable = true;

  users.defaultUserShell = pkgs.zsh;

  environment.systemPackages = with pkgs; [
    #outside deps
    # Tree
    tree
    (writeShellScriptBin "t" ''tree -C $@ '')

    #ls alias
    (writeShellScriptBin "l" ''ls -la $@ '')

    # Templates
    (import ../templates/default.nix {
      inherit pkgs;
      templatesFolder = "${toString (import ../pkgsPath.nix)}/templates";
      installCommand = ''
        sudo nixos-rebuild switch --flake ${toString (import ../pkgsPath.nix)}
      '';
      difftool = pkgs.writeShellScript "difftool" ''
        ${import ../vim/nvim.nix { inherit pkgs;}}/bin/vimdiff $1 $2
      '';
    })
    

    nix-alien
    vifm
    fzf
    git
    xclip
    nixos-generators
    # require unsafe python
    # nixops
    traceroute
    file
  ];
}
