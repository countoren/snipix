#!/usr/bin/env bash
set -e


echo "Restoring etc/bashrc"
sudo mv /etc/bashrc.backup-before-nix /etc/bashrc

echo "Restoring etc/zshrc"
sudo mv /etc/zshrc.backup-before-nix /etc/zshrc

echo "Removing nix"
sudo rm -rf /etc/nix /nix /var/root/.nix-profile /var/root/.nix-defexpr /var/root/.nix-channels /Users/orenrozen/.nix-profile /Users/orenrozen/.nix-defexpr /Users/orenrozen/.nix-channels
