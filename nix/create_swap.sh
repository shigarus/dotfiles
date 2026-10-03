#!/usr/bin/env sh
# in case of nix switch oom
sudo fallocate -l 16G /var/lib/swapfile
sudo chmod 600 /var/lib/swapfile
sudo mkswap /var/lib/swapfile
sudo swapon /var/lib/swapfile
