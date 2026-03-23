{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # CLI essentials
    fzf
    fd
    bat
    ripgrep
    btop
    curl
    wget
    unzip
    tree
    gemini-cli

    # Dev tools
    neovim
    gcc
    cmake
    mise

    # Nix tools
    nixfmt-rfc-style
    nix-tree

    # Container & K8s
    podman
    podman-compose
    kubectl
    kubernetes-helm
    k9s
    kubectx
    kind
  ];
}
