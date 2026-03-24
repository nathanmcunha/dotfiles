{ pkgs, claude-code, system, lib, ... }:

{
  home.activation.installRtk = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if ! command -v rtk &>/dev/null; then
      $DRY_RUN_CMD ${pkgs.bash}/bin/sh -c '
        export PATH="${pkgs.curl}/bin:${pkgs.bash}/bin:${pkgs.coreutils}/bin:${pkgs.gnutar}/bin:${pkgs.gzip}/bin:$PATH"
        curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh
      '
    fi
  '';

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
    nixfmt
    nix-tree

    # Container & K8s
    podman
    podman-compose
    kubectl
    kubernetes-helm
    k9s
    kubectx
    kind

    #Claude Code
    claude-code.packages.${system}.default

  ];
}
