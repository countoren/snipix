let
  all-hies = import (fetchTarball "https://github.com/infinisil/all-hies/tarball/master") {};
in 
  (all-hies.selection { selector = p: { inherit (p) ghc865; }; })
