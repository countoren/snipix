#!/usr/bin/env bash
set -e

#pre install scripts 
if [ $1 = "mac-core" ]; then
	#application to install manually
	#dropbox
	open https://www.dropbox.com/download?plat=mac
	#google drive
	open https://www.google.com/drive/download/
	#virtual box
	open https://download.virtualbox.org/virtualbox/5.2.16/VirtualBox-5.2.16-123759-OSX.dmg
fi

echo "Installing nix"
curl https://nixos.org/nix/install | sh
echo 'Loading nix enviorment to current shell'
. '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'


if [ -f "$HOME/Dropbox/nixpkgs/config.nix" ]; then
			echo "creating config.nix and linking it to Dropbox config.nix..."
      mkdir -p ~/.nixpkgs
			#if exists config.nix backup it
			mv -vn ~/.nixpkgs/config.nix ~/.nixpkgs/config.beforeDP 2>/dev/null

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

echo "installing $1"
nix-env -i $1

eval 'homeInstall'
#On Macos fixup scripts
if [ $1 = "mac-core" ]; then
	eval 'startApps'
fi
