#!/usr/bin/env sh
if [ "$(awk -F= '$1=="ID" {print $2}' /etc/os-release)" = "nixos" ]; then
    sudo nixos-rebuild switch --flake ~/dotfiles/nix#nixos
elif [ "$(uname -s)" = "Darwin" ]; then
    sudo nix run nix-darwin/master#darwin-rebuild --extra-experimental-features nix-command --extra-experimental-features flakes -- switch --flake ~/dotfiles/nix#mac-serios
else
    home-manager switch --flake ~/dotfiles/nix#rog-ally
fi
