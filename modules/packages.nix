{
  pkgs,
  inputs,
  ...
}:
{
  home.packages = with pkgs; [
    # CLI essentials
    fzf
    bat
    btop
    tree
    eza
    zoxide
    gh
    gemini-cli
    jq
    pass
    inputs.impala.packages.${pkgs.system}.default

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

    # Wayland / Hyprland apps
    playerctl
    hyprsunset
    hypridle
    hyprpaper
    wl-clipboard
    wl-clip-persist
    grim
    slurp
    swappy
    wf-recorder
    libnotify
    pamixer
    brightnessctl
    pulsemixer
    pavucontrol
    networkmanagerapplet

    # Theming
    adw-gtk3
    qt6Packages.qt6ct
    nwg-look
    bibata-cursors
    papirus-icon-theme

    # Desktop apps
    libreoffice
    bitwarden-desktop
    bitwarden-cli
    protonup-ng
    vscode
    audacity
    appimage-run
    imagemagick
    ffmpeg
    xclip

    # File manager
    nautilus

    # Terminal
    alacritty

    # Browser
    brave

    # Media
    mpv
    vlc
    freetube

    # Image / Documents
    imv
    zathura

    # System info
    blueman
    cpu-x
    fastfetch

    vial
    ytmdesktop
  ];
}
