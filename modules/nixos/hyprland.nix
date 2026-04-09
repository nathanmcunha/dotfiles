{
  config,
  pkgs,
  inputs,
  ...
}:

{
  imports = [ inputs.hyprland.nixosModules.default ];

  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    withUWSM = true;
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    QT_QPA_PLATFORM = "wayland";
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";
  };

  environment.systemPackages = with pkgs; [
    # Wayland essentials
    awww
    hypridle
    hyprlock
    hyprpaper

    # Clipboard
    cliphist
    wl-clipboard
    wl-clip-persist

    # Notifications
    dunst
    libnotify

    # Launcher & Bar
    wofi
    waybar

    # Logout menu
    wlogout

    # Screenshots & Recording
    grim
    slurp
    swappy
    wf-recorder

    # Volume & Brightness
    pamixer
    brightnessctl
    pulsemixer
    pavucontrol

    # Network
    networkmanagerapplet

    # File managers
    nautilus

    # Terminal
    alacritty

    # Browser
    brave

    # Media players
    mpv
    vlc
    freetube

    # Image viewer
    imv

    # Documents
    zathura

    # Gaming
    lutris

    # System tools
    blueman
    cpu-x
    fastfetch

    # Fonts
    noto-fonts
    noto-fonts-color-emoji
  ];

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  security.polkit.enable = true;
}
