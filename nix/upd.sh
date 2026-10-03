#!/usr/bin/env sh
if [ "$(awk -F= '$1=="ID" {print $2}' /etc/os-release)" = "nixos" ]; then
    sudo nixos-rebuild switch --flake ~/dotfiles/nix#nixos
else
    home-manager switch --flake ~/dotfiles/nix.#rog-ally
fi
