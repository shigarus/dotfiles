# Home-manager for arch

``` bash
#
REPO_PATH="~/prjs/nixos"
if ! command -v pacman >/dev/null 2>&1
then
    echo "this is not arch, install nix some other way."
    exit 1
fi
sudo pacman -S nix
sudo systemctl enable nix-daemon
sudo systemctl start nix-daemon
## seems not needed as such group does not exists and everything works without
# sudo gpasswd -a <user> nix-users
nix-channel --add https://nixos.org/channels/nixpkgs-unstable
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update
export NIX_PATH=$HOME/.nix-defexpr/channels:/nix/var/nix/profiles/per-user/root/channels${NIX_PATH:+:$NIX_PATH}
nix-shell '<home-manager>' -A install
echo 'experimental-features = nix-command flakes' | sudo tee -a /etc/nix/nix.conf
mkdir -p $REPO_PATH
nix shell nixpkgs#git --command git clone git@github.com:shigarus/nixos.git $REPO_PATH
cd $REPO_PATH
./upd.sh
```

## tailscale
TODO: Already was installed when this doc is written, add later
