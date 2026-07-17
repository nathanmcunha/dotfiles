{
  pkgs,
  inputs,
  ...
}:
{

  home = {
    packages = with pkgs; [
      # CLI essentials
      monique
      pass
      inputs.impala.packages.${pkgs.stdenv.hostPlatform.system}.default
      fabric-ai

      # Dev tools
      gnupg
      gradle
      maven
      sshfs

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

      #AI
      inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.omp
      inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.rtk
      inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.skills

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
      discord

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

      hydralauncher

      vial
      easyeffects
      exercism
    ];
  };
}
