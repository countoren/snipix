#!/usr/bin/env bash
set -e

echo "Uninstalling nix"
echo "Removing nix"
rm -rf $HOME/{.nix-channels,.nix-defexpr,.nix-profile,.config/nixpkgs}
sudo rm -rf /nix

