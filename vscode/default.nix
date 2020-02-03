{
  vscodeEnv
}:
{
  mutableExtensionsFile,
  nixExtensions ? []
}:
with builtins;
vscodeEnv {
  nixExtensions = 
  [
    { name = "gitlens"; publisher = "eamodio"; version = "10.2.0"; 
    sha256 = "0qnq9lr4m0j0syaciyv0zbj8rwm45pshpkagpfbf4pqkscsf80nr";  }

    { name = "run-on-save"; publisher = "pucelle"; version = "1.1.4"; 
    sha256 = "1fz5m8k313mnms1gzsfkpl7wbqqdjkmwydx62pvi3q2qwb6n4jpw";  }

    { name = "theme-obsidian"; publisher = "rprouse"; version = "0.3.1"; 
    sha256 = "17a1m4mmsn80ai9vrh9zilrwh2jxfxj09fk2w857i68a7yvyhf7c";  }

    { name = "vim"; publisher = "vscodevim"; version = "1.12.4"; 
    sha256 = "1l8ich2w3hjnwl3ihgr4cr00lwvas4zrsdh2f8gv3vi0aa40vc9n";  }
  ] ++ nixExtensions;
  settings= fromJSON (readFile (toPath ./settings.json));
  keybindings= fromJSON (readFile (toPath ./keybindings.json));
  inherit mutableExtensionsFile;
}
