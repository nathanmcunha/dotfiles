{
  pkgs,
  claude-code,
  system,
  ...
}:

{
  home.packages = with pkgs; [
    # CLI essentials
    fd
    bat
    ripgrep
    curl
    wget
    unzip
    tree
    eza
    gh
    gemini-cli
    jq
    pass
    zoxide

    # Dev tools
    neovim
    gcc
    cmake
    mise
    pinentry-tty
    gnupg
    go
    gradle
    temurin-bin-21
    maven
    nodejs_24
    python312
    rustup
    direnv
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

    # Claude Code
    claude-code.packages.${system}.default

    # Kilocode CLI
    kilocode-cli
    github-copilot-cli

    # Java, AI & desktop tools
    google-java-format
    opencode

    # Wayland apps & Desktop integration
    playerctl
    swappy
    libnotify
    pamixer
    brightnessctl
    pulsemixer
    pavucontrol
    networkmanagerapplet

    # Theming
    sassc
    gtk-engine-murrine
    bibata-cursors

    # Desktop apps
    telegram-desktop
    libreoffice
    bitwarden-desktop
    bitwarden-cli
    protonup-ng
    audacity
    appimage-run
    xclip # Keep for XWayland compatibility if needed

    # File manager
    nautilus

    vial
    ytmdesktop
  ];
}
