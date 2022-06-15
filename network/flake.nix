{
  description = "Network Util";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-21.11";
  };

  outputs = { self, nixpkgs, ... }: 
  let 
     system = "x86_64-linux";
     pkgs = import nixpkgs { inherit system; };
     lib = nixpkgs.lib;
  in {
    defaultTemplate = {
      path = ./.;
      description = "network example of CLI tools with recursive strcuture";
    };

    nixosModule = {config, ...} : { 
      config = { 
        environment.systemPackages = [ self.defaultPackage.${system} ]; 

        services.xserver.desktopManager.gnome.extraGSettingsOverrides = ''
          [org/gnome/settings-daemon/plugins/media-keys]
          custom-keybindings=['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/
          ']

          [org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0]
          binding='<Primary><Shift>w'
          command='nmcli radio wifi off'
          name='wifi'
        '';
      };
    };

    defaultPackage.${system} = import ./default.nix { inherit pkgs; };
    defaultApp.${system} = self.defaultPackage.${system};
  };
}
