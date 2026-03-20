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

    # Dev tools
    neovim
    mise
    gcc
    cmake

    # Nix tools
    nixfmt-rfc-style
    nix-tree
  ];
}
