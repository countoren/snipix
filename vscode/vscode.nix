{ pkgs             ? import <nixpkgs> {}
, nixExtensions        ? []
, mutableExtensionFile ? ./extensions.nix
}:
with pkgs;

let
  les = [ 
    {
      name = "csharp";
      publisher = "ms-vscode";
      version = "1.21.5";
      sha256 = "031yx2kpjrw1b86y5nq110k9ywjgl26730ljddly05d8fxxham05";
    } 
    { name = "vim";
      publisher = "vscodevim";
      version = "0.16.13";
      sha256 = "02bfld819nrsik17zyzckbv8vfz28hdlnkx4id7kx54f41y5kx0v";
    }
    ];
  lextensions = pkgs.vscode-utils.extensionsFromVscodeMarketplace les;
  es = vscode-personal.extensions;
  extensions = pkgs.vscode-utils.extensionsFromVscodeMarketplace es;
  rmExtensions = ''
    find exts -mindepth 1 -maxdepth 1 ${lib.concatMapStringsSep " " (e : ''! -iname ${e.publisher}.${e.name}'') (es++les)} -exec sudo rm -rf {} \;
    '';
  cpExtensions = ''
    ${lib.concatMapStringsSep "\n" (e : ''ln -sfn ${e}/share/vscode/extensions/* exts/'') extensions}
    ${lib.concatMapStringsSep "\n" (e : ''cp -a ${e}/share/vscode/extensions/* exts/'') lextensions} 2>/dev/null
  '';

  vc = writeShellScriptBin "code" ''
    mkdir -p exts 
    ${rmExtensions}
    ${cpExtensions}

    ${vscode}/bin/code --extensions-dir exts "$@"
  '';

  vscodeExts2nix = writeShellScriptBin "vscodeExts2nix" ''
    echo '[' 

    for line in $(${vc}/bin/code --list-extensions --show-versions \
      | grep -v -i '^\(${lib.concatMapStringsSep "\\|" (e : ''${e.publisher}.${e.name}'') es}\)' 
    ) ; do
      [[ $line =~ ([^.]*)\.([^@]*)@(.*) ]]
      name=''${BASH_REMATCH[2]}
      publisher=''${BASH_REMATCH[1]}
      version=''${BASH_REMATCH[3]}

      localExts="${lib.concatMapStringsSep "." (e : ''${e.publisher}${e.name}@${e.sha256}'') les}"
      reCurrentExt=$publisher$name"@([^.]*)"
      if [[ $localExts =~ $reCurrentExt ]]; then
        sha256=''${BASH_REMATCH[1]}
      else
        sha256=$(
          nix-prefetch-url "https://"$publisher".gallery.vsassets.io/_apis/public/gallery/publisher/"$publisher"/extension/"$name"/"$version"/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage" 2> /dev/null
        )
      fi

      echo "{ name = \"''${name}\"; publisher = \"''${publisher}\"; version = \"''${version}\"; sha256 = \"''${sha256}\";  }"
    done


    echo ']'
  '';
in buildEnv {
  name = "dfsf";
  paths = [ vscodeExts2nix vc ];
}
