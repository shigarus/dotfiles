#!/usr/bin/env sh
if [ "$(awk -F= '$1=="ID" {print $2}' /etc/os-release)" = "nixos" ]; then
    sudo nixos-rebuild switch --flake ~/nixos#nixos
else
    home-manager switch --flake .#rog-ally
fi
