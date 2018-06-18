{stdenv}: dotfilePath:
let dotfileName = baseNameOf dotfilePath;
in
stdenv.mkDerivation {
    name = dotfileName;

    phases = [ "installPhase" ];

    src = dotfilePath;

    installPhase = ''
      install -dm 755 $out/userHome
      substitute $src $out/userHome/.''+dotfileName;
}
