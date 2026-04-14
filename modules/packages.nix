{
  pkgs,
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
    pinentry-tty
    gnupg
    go
    gradle
    temurin-bin-21
    maven
    nodejs_24
    python312
    rustup

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

    # AI CLIs
    kilocode-cli
    github-copilot-cli
    google-java-format
    opencode

    # Wayland apps
    waybar
    wofi
    dunst
    wlogout
    playerctl
    hyprsunset
    swappy
    libnotify
    pamixer
    brightnessctl
    pulsemixer
    pavucontrol
    networkmanagerapplet

    # Theming
    matugen
    wpgtk
    pywal
    awww
    sassc
    gtk-engine-murrine
    bibata-cursors

    # Desktop apps
    libreoffice
    bitwarden-desktop
    bitwarden-cli
    protonup-ng
    vscode
    audacity
    appimage-run
    imagemagick
    xclip

    # File manager
    nautilus

    vial
    ytmdesktop

  ];
}
