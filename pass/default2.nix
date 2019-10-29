{ pkgs ? import <nixpkgs>{} }:
with pkgs;
stdenv.mkDerivation rec {
	name = "psl";
	buildInputs = [ pass ];

  
}
rec {

    shellIntoPkgScript = (pkg : ''nix-shell -E "with import <nixpkgs> {}; ${pkg}"'');

    psl = writeShellScriptBin "psl" (shellIntoPkgScript "passShell");

    passShell = mkShell {
      buildInputs = [ 
        pass 
      ];
    
      shellHook = ''
        trap "popd" EXIT
        pushd ~/.password-store
        complete -W 'a d' pass

        alias p=pass
      '';
    };
}
