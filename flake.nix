{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-20.03";

  outputs = { self, nixpkgs }: 
  let pkgs = import nixpkgs { system = "x86_64-darwin"; };
    lpkgs = import nixpkgs { system = "x86_64-linux"; };
  in 
  {
    defaultApp.x86_64-linux = lpkgs.writeShellScriptBin "bla" ''echo dlfkjdlskfdj'';
    defaultApp.x86_64-darwin = pkgs.writeShellScriptBin "bla" ''echo dlfkjdlskfdj'';
    nixosConfigurations.container = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules =
        [ ({ pkgs, ... }: {
            boot.isContainer = true;

            # Let 'nixos-version --json' know about the Git revision
            # of this flake.
            system.configurationRevision = nixpkgs.lib.mkIf (self ? rev) self.rev;

            # Network configuration.
            networking.useDHCP = false;
            networking.firewall.allowedTCPPorts = [ 80 ];

            # Enable a web server.
            services.httpd = {
              enable = true;
              adminAddr = "morty@example.org";
            };
          })
        ];
    };

  };
}
