{
  pkgs,
  claude-code,
  system,
  ...
}:

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
    eza
    zsh-fzf-tab
    zoxide
    gh
    gemini-cli
    jq
    pass
    # Dev tools
    neovim
    gcc
    cmake
    mise
    pinentry-tty
    pass
    gnupg 

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

    # Java, AI & desktop tools
    google-java-format
    opencode
    elephant

  ];
}
