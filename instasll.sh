#!/usr/bin/env bash
set -e

echo "Installing nix profile"
#nix-env -i all

pushd $HOME > /dev/null

echo "Creating dotfiles links in user home"

ls -A .nix-profile/userHome/ | xargs -I {} ln -sf .nix-profile/userHome/{} {}

popd > /dev/null

echo "Done"
