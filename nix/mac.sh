#!/usr/bin/env bash
curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install | sh
# To use Nixpkgs 26.05:
sudo nix run nix-darwin/nix-darwin-26.05#darwin-rebuild --extra-experimental-features nix-command --extra-experimental-features flakes -- switch
