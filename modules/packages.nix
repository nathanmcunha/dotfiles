{
  pkgs,
  inputs,
  ...
}:
{

  home.packages = with pkgs; [
    # CLI essentials
    bat
    tree
    eza
    ripgrep
    fd
    jq
    pass
    rtk
    inputs.impala.packages.${pkgs.stdenv.hostPlatform.system}.default

    # Dev tools
    neovim
    gcc
    cmake
    gnupg
    go
    gradle
    temurin-bin-21
    maven
    jetbrains.idea
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
    github-copilot-cli
    google-java-format
    opencode
    pi-coding-agent
    (pkgs.callPackage ../derivations/antigravity-cli.nix { })

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
    bitwarden-cli
    protonup-ng
    vscode
    audacity
    appimage-run
    imagemagick
    ffmpeg
    xclip
    xournalpp

    # File manager
    nautilus

    # Browser
    brave
    google-chrome

    # Media
    mpv
    vlc

    # Image / Documents
    imv
    zathura

    # System info
    blueman
    cpu-x
    fastfetch

    oci-cli
    vial
    easyeffects
    android-tools

    (bun.overrideAttrs (old: {
      version = "1.3.14";
      src = pkgs.fetchurl {
        url = "https://github.com/oven-sh/bun/releases/download/bun-v1.3.14/bun-linux-x64.zip";
        hash = "sha256-lR7iruhV8IWVruxiJSJqKY0/6oOj3NZGXAnLzN9+hI8=";
      };
    }))
    wireshark
    (writeShellScriptBin "omp" ''
      exec ${bun}/bin/bunx @oh-my-pi/pi-coding-agent "$@"
    '')
  ];
}
