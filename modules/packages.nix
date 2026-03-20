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
    gcc
    cmake
    mise

    # Nix tools
    nixfmt-rfc-style
    nix-tree
  ];
}
