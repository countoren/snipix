#!/usr/bin/env bash
set -e

echo "Installing nix"
curl https://nixos.org/nix/install | sh
if [ ! -d ~/.nixpkgs ]; then
	echo "Installing git"
	/nix/var/nix/profiles/default/bin/nix-env -i git
	echo "cloning my nix packages"
	git clone https://github.com/countoren/nixpkgs.git ~/.nixpkgs
fi
echo "installing HomeInstall"
/nix/var/nix/profiles/default/bin/nix-env -i homeInstall
echo "running homeInstall"
homeInstall
