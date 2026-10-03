{ config, pkgs, ... }:
{
  programs.ghostty = { enable = true; };
  home.sessionVariables = {
    EDITOR = "nvim";
  };
  home.packages = with pkgs; [
    bat
    btop
    cargo
    dig
    fd
    fish-lsp
    fzf
    emacs
    eza
    gcc
    git
    git-credential-manager
    git-lfs
    grpcurl
    jfrog-cli
    jq
    jwt-cli
    kubectl
    kubie
    k9s
    maven
    neovim
    nodejs
    parallel
    ripgrep
    shellcheck
    shfmt
    terraform
    tilt
    tldr
    tree-sitter
    tmux
    starship
    stow
    unzip
    vhs
    yazi
    yq
    zoxide
  ];
}
