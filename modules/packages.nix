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

    # Kilocode CLI
    kilocode-cli
    github-copilot-cli

    # Java, AI & desktop tools
    google-java-format
    opencode
    elephant

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
    gnome-themes-extra
    gtk-engine-murrine
    bibata-cursors

    # Desktop apps (from services.nix)
    telegram-desktop
    libreoffice
    bitwarden-desktop
    bitwarden-cli
    protonup-ng
    vscode
    audacity
    gnome-tweaks
    appimage-run
    imagemagick
    xclip

    # File manager
    nautilus
  ];
}
