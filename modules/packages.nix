{
  pkgs,
  inputs,
  ...
}:
{

  home = {
    packages = with pkgs; [
      # CLI essentials
      bat
      eza
      ripgrep
      fd
      jq
      monique
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
      (pkgs.callPackage ../derivations/antigravity-cli.nix { })
      mimo
      google-cloud-sdk

      # Wayland / Hyprland apps
      playerctl
      hyprsunset
      hyprpaper
      wl-clipboard
      wl-clip-persist
      grim
      slurp
      swappy
      libnotify
      brightnessctl
      pulsemixer
      pavucontrol
      networkmanagerapplet

      # Theming
      qt6Packages.qt6ct
      nwg-look

      # Desktop apps
      libreoffice
      bitwarden-cli
      protonup-ng
      vscode
      appimage-run
      imagemagick
      ffmpeg
      xournalpp
      pear-desktop

      # File manager
      nautilus

      # Browser
      brave
      google-chrome
      inputs.helium.packages.${pkgs.stdenv.hostPlatform.system}.default

      # Media
      mpv
      vlc

      # Image / Documents
      imv
      zathura

      # System info
      fastfetch

      vial
      easyeffects
      exercism
      (writeShellScriptBin "omp" ''
        exec ${bun}/bin/bunx @oh-my-pi/pi-coding-agent "$@"
      '')
    ];
  };
}
