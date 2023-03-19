# save as sd-image.nix somewhere
{ pkgs, ... }: {
  imports = [
    <nixpkgs/nixos/modules/installer/sd-card/sd-image-aarch64.nix>
  ];

  /*
  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  boot.kernelPackages = pkgs.linuxPackages;
  boot.kernelParams = ["cma=256M"];
  boot.loader.raspberryPi.enable = true;
  boot.loader.raspberryPi.version = 3;
  boot.loader.raspberryPi.uboot.enable = true;
  boot.loader.raspberryPi.uboot.configurationLimit = 3;
  boot.loader.raspberryPi.firmwareConfig = ''
   gpu_mem=256
  '';

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  networking.useDHCP = false;


  swapDevices = [ { device = "/swapfile"; size = 1024; } ]; 

  hardware.firmware = [ pkgs.wireless-regdb ];
  environment.systemPackages = with pkgs; [ libraspberrypi vim bash ];
  */

  # put your own configuration here, for example ssh keys:
  services.openssh.enable = true;
  services.openssh.permitRootLogin = "yes";

  users.users.oren = {
    isNormalUser = true;
    home = "/home/oren";
    shell = pkgs.bash;
    description = "oren";
    extraGroups = [ "wheel" "networkmanager" ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCzUleZonbfty2Xm0lVvrceclsrPjTgAxQQgfSLwqNWgSBi960GZXEmKjWX9ni4ZZFBeTiUD2FUAnsppQBZQLFsYccW0qe0fbvK6OdJQkk/So3E/VGuKnAg/4yE3e9iw68tuKYGyqwdVg8IAJAwDn4NfCYg5WiaVrBfdFbtJfVhdcU8Ygx6toJ5JwubKqSIXVAL1590JnKZoFO/YHkwBARIhcnkEmwz+zWKjPQJ3dkJ8s9yx+P820PwGdg/0gUM4EU/CYEjmkHHR81lCx3tmRUVyCooT5uqTejkA/ELaWCCJ4WRfUGk+o4EzzwHzzqMrjZY9ptLA/jx65evtQ+Iwsh4MoyPgyaK+HS4rNCVoHdQINiobHw71Fh47USHzvfuc3qRJ0ITCvWRXCDraX1K4i0bTSNH1w09RkYcbzUU/zA/enNQYMrVUtNImWwL/6uXKaadZprgFUSAzUyg2K9IT3MY8Fy3hQbxNzDltAJuan8UaOP+Y6R/fKkzUMLS6r5uGmM= p1n3@p1n3"
    ];
  };
}
