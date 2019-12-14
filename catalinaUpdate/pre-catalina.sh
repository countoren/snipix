#!/usr/bin/env bash
set -e
set -u
nix-collect-garbage
sudo launchctl unload /Library/LaunchDaemons/org.nixos.nix-daemon.plist
(echo 'nix'; echo -e 'run\tprivate/var/run') | sudo tee -a /etc/synthetic.conf >/dev/null
sudo mv /nix /was-nix
sudo mkdir /nix
PASSPHRASE=$(openssl rand -base64 32)
echo "Creating encrypted APFS volume with passphrase: $PASSPHRASE" >&2
sudo diskutil apfs addVolume disk1 'Case-sensitive APFS' Nix -mountpoint /nix -passphrase "$PASSPHRASE"
UUID=$(diskutil info -plist /nix | plutil -extract VolumeUUID xml1 - -o - | plutil -p - | sed -e 's/"//g')
security add-generic-password -l Nix -a "$UUID" -s "$UUID" -D "Encrypted Volume Password" -w "$PASSPHRASE" \
 -T "/System/Library/CoreServices/APFSUserAgent" -T "/System/Library/CoreServices/CSUserAgent"
sudo diskutil enableOwnership /nix
echo 'LABEL=Nix /nix apfs rw' | sudo tee -a /etc/fstab >/dev/null
echo "Copying nix to new volume.." >&2
sudo rsync -aH /was-nix/ /nix/
sudo launchctl load /Library/LaunchDaemons/org.nixos.nix-daemon.plist
echo 'Waiting for nix-daemon..' >&2
while ! nix ping-store >/dev/null 2>&1; do
echo -n '.' >&2
    sleep 1
done
echo >&2
sudo rm -r /was-nix
echo "Done!" >&2
