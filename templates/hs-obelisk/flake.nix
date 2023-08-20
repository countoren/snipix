{
  inputs.obs.url = github:obsidiansystems/obelisk;
  outputs = { self, nixpkgs, obs }:
  let system = "x86_64-linux";
  pkgs = import nixpkgs {inherit system; };
  in
  {
    packages.${system}.default = (import ./default.nix { inherit system; }).command;
    devShells.${system}.default = pkgs.mkShell {
      name = "test";
      buildInputs = [
        (import ./default.nix { inherit system; }).command
      ];
    };
  };
  nixConfig = {
    extra-substituers = [ "https://nixcache.reflex-frp.org" ];
    extra-trusted-public-keys = [ "ryantrinkle.com-1:JJiAKaRv9mWgpVAz8dwewnZe0AzzEAzPkagE9SP5NWI=" ];
  };
}
