{ pkgs?  import <nixpkgs>{} 
, username ? "p1n3"
, keyId ? "countoren@gmail.com"
, usbName ? "Untitled\ 2"
}: 
with pkgs;
#when prompt by --edit-key enter: trust, 5, y    
writeShellScriptBin "mygpginit" ''
  sudo chown -R ${username} /run/media/${username}/${usbName}/password-store
  ${gnupg}/bin/gpg --import /run/media/${username}/${usbName}/pub.key
  ${gnupg}/bin/gpg --import /run/media/${username}/${usbName}/prv.key
  ${gnupg}/bin/gpg --edit-key ${keyId}
''
