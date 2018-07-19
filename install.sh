#!/usr/bin/env bash
set -e

echo "what enviorment to install?"
read env

echo "Installing nix"
curl https://nixos.org/nix/install | sh
echo 'Loading nix enviorment to current shell'
. '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'


if [ -f "$HOME/Dropbox/nixpkgs/config.nix" ]; then
			echo "creating config.nix and linking it to Dropbox config.nix..."
      mkdir -p ~/.nixpkgs
      echo "import ~/Dropbox/nixpkgs/config.nix" > ~/.nixpkgs/config.nix
elif [ ! -d ~/.nixpkgs ]; then
	echo "Installing git"
	nix-env -i git
	echo "cloning my nix packages"
	git clone https://github.com/countoren/nixpkgs.git ~/.nixpkgs
fi

echo 'Regsitering to unstable channel...'
nix-channel --add https://nixos.org/channels/nixpkgs-unstable
nix-channel --update
echo 'Regsitered to unstable channel'

echo "installing HomeInstall"
nix-env -i homeInstall
echo "running homeInstall"
eval 'homeInstall'

echo installing $env
eval 'nix-env -i $env'
