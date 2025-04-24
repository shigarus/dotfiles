#!/usr/bin/env bash
for i in $(awk '{print $1}' ./ppa);
do
sudo add-apt-repository $i
done
sudo apt-get install $(awk '{print $1}' ./common_apps)
sudo apt-get install $(awk '{print $1}' ./ubuntu_apps)
if ! command -v starship 2>&1 >/dev/null
then
  curl -sS https://starship.rs/install.sh | sh
fi

if ! command -v zoxide 2>&1 >/dev/null
then
  curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
fi

if ! command fisher 2>&1 >/dev/null
then
  curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher
  fisher install PatrickF1/fzf.fish
fi
if ! command cargo 2>&1 >/dev/null
then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
fi

if ! command kubie 2>&1 >/dev/null
then
  cargo install kubie
fi

if ! command eza 2>&1 >/dev/null
then
  cargo install eza
fi

if ! command lazygit 2>&1 >/dev/null
then
  LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | \grep -Po '"tag_name": *"v\K[^"]*')
  curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
  tar xf lazygit.tar.gz lazygit
  sudo install lazygit -D -t /usr/local/bin/
fi

./install-krew.sh

if ! command kubectx 2>&1 >/dev/null
then
  sudo git clone https://github.com/ahmetb/kubectx /opt/kubectx
  sudo ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx
  sudo ln -s /opt/kubectx/kubens /usr/local/bin/kubens
fi

if ! command k9s 2>&1 >/dev/null
then
  wget https://github.com/derailed/k9s/releases/latest/download/k9s_linux_amd64.deb && apt install ./k9s_linux_amd64.deb && rm k9s_linux_amd64.deb
fi

if ! command ctlptl 2>&1 >/dev/null
then
  go install github.com/tilt-dev/ctlptl/cmd/ctlptl@latest
fi

if ! command tilt 2>&1 >/dev/null
then
  go install github.com/tilt-dev/ctlptl/cmd/ctlptl@latest
fi

if ! command kubebuilder 2>&1 >/dev/null
then
  curl -L -o kubebuilder "https://go.kubebuilder.io/dl/latest/$(go env GOOS)/$(go env GOARCH)"
  chmod +x kubebuilder && sudo mv kubebuilder /usr/local/bin/
fi

if ! command tmux 2>&1 >/dev/null
then
  git clone https://github.com/tmux/tmux.git ~/.tmux-git
  cd ~/.tmux-git
  sh autogen.sh
  ./configure
  make && sudo make install
fi

if [ ! -d "~/.tmux/plugins/tpm" ]; then
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi


sudo snap install nvim --classic

echo "----------------------"
echo "----------------------"
echo "----------------------"
echo "INSTALL GO MANUALLY!!!!!"
echo "probably you also need to install export TERM=xterm-256color to bashrc if you are using a vm via SSH"
