{ pkgs,... }:
let networkUtils = import ./. { inherit pkgs; };
in
  {
    dconf.settings = {
      "org/gnome/settings-daemon/plugins/media-keys" = {
        custom-keybindings = [
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
        ];
      };
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
        binding = "Insert";
        command = "${networkUtils}/bin/onm";
        name = "wifi";
      };
    };
  }
