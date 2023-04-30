{
  outputs = { self }:
  # flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
  # flake-utils.lib.eachDefaultSystem (system:
  rec {
    templates = {
      basic = {
        description = "basic flake"; 
        path = ./basic; 
      };
      default = templates.basic;
    };
  };
}
