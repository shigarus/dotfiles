#!/usr/bin/env sh

sudo pacman -Syu docker

# Power button setup
printf '%s\n' \
  'HandlePowerKey=suspend' \
  'HandlePowerKeyLongPress=poweroff' |
  sudo tee -a /etc/systemd/logind.conf >/dev/null

# remove dutch locale
sudo sed -i '/nl_NL/d' /etc/locale.conf

# browser, there is no clean way installing it from home-manager yet
# only some third-party flakes I don't want to use
sudo pacman -Suy zen-browser

# to control TDP, requires service
sudo pacman -Suy asusctl rog-control-center

echo "INSTALL TAILSCALE SOMEHOW, THE KNOWLEDGE IS LOST"
