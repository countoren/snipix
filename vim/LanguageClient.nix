{ pkgs ? import <nixpkgs>{}
}:
with pkgs;
let
  inherit (darwin.apple_sdk.frameworks) Cocoa CoreFoundation CoreServices;
  
  version = "0.1.161";
  LanguageClient-neovim-src = fetchFromGitHub {
    owner = "autozimu";
    repo = "LanguageClient-neovim";
    rev = "a734a05ba72280e0617bb96c0585283aebd46a5f";
    sha256 = "05ljbyqyl5w703hbjfwm4rndnkbsxdikbxbvwlf0piymmbns3qk5";
  };
  LanguageClient-neovim-bin = rustPlatform.buildRustPackage {
    pname = "LanguageClient-neovim-bin";
    inherit version;
    src = LanguageClient-neovim-src;

    cargoSha256 = "11imx7ngi00bc84gplr8x4afx7nwziif1hl7nk0siklnkcw1qr9k";
    buildInputs = lib.optionals stdenv.isDarwin [ CoreServices ];

        # FIXME: Use impure version of CoreFoundation because of missing symbols.
        #   Undefined symbols for architecture x86_64: "_CFURLResourceIsReachable"
        preConfigure = lib.optionalString stdenv.isDarwin ''
          export NIX_LDFLAGS="-F${CoreFoundation}/Library/Frameworks -framework CoreFoundation $NIX_LDFLAGS"
        '';
      };
in
  vimUtils.buildVimPluginFrom2Nix {
    pname = "LanguageClient-neovim";
    inherit version;
    src = LanguageClient-neovim-src;

    propagatedBuildInputs = [ LanguageClient-neovim-bin ];

    preFixup = ''
        substituteInPlace "$out"/share/vim-plugins/LanguageClient-neovim/autoload/LanguageClient.vim \
          --replace "let l:path = s:root . '/bin/'" "let l:path = '${LanguageClient-neovim-bin}' . '/bin/'"
    '';
  }
