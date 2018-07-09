{mkDerivation, writeText}:  
let 
  createDotExp = 
    dotFileSrc: dotfileName: 
    mkDerivation {
        name = dotfileName;
        phases = [ "installPhase" ];
        src = dotFileSrc;
        installPhase = ''
          install -dm 755 $out/userHome
          substitute $src $out/userHome/.''+dotfileName;
  };
in {
  toDotfile = dfPath: createDotExp dfPath (baseNameOf dfPath); 
  toDotfileWithDeps = dfPath: deps: 
  let 
    fileName = (baseNameOf dfPath);
    fileContent = import dfPath deps;
    dotfileNix = writeText fileName fileContent;
  in
    createDotExp dotfileNix fileName;
}

