#!/usr/bin/env bash
set -e

echo "Installing nix"
curl https://nixos.org/nix/install | sh
echo 'Loading nix enviorment to current shell'
. '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
if [ ! -d ~/.nixpkgs ]; then
	echo "Installing git"
	nix-env -i git
	echo "cloning my nix packages"
	git clone https://github.com/countoren/nixpkgs.git ~/.nixpkgs
fi
echo "installing HomeInstall"
nix-env -i homeInstall
echo "running homeInstall"
homeInstall
