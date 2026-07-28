{
  pkgs,
  lib,
  ...
}:

let
  gtkTheme = {
    name = "adw-gtk3";
    package = pkgs.adw-gtk3;
  };
in
{
  home.username = "nathanmcunha";
  home.homeDirectory = "/home/nathanmcunha";
  home.stateVersion = "26.05";
  home.enableNixpkgsReleaseCheck = false;

  programs.home-manager.enable = true;
  programs.gpg.enable = true;
  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    enableZshIntegration = true;
    pinentry.package = pkgs.pinentry-qt;
    defaultCacheTtl = 28800;
    maxCacheTtl = 28800;
    extraConfig = ''
      allow-loopback-pinentry
    '';
  };
  # fabric-ai.enableZshIntegration = true;

  gtk = {
    enable = true;
    theme = gtkTheme;
    gtk4.theme = gtkTheme;
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    cursorTheme = {
      name = "Bibata-Modern-Classic";
      package = pkgs.bibata-cursors;
      size = 24;
    };
  };

  home.activation.installIcons = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "$HOME/.icons/default"
    printf '[Icon Theme]\nName=Default\nInherits=Bibata-Modern-Classic\n' > "$HOME/.icons/default/index.theme"
  '';

  xdg.configFile = {
    "gtk-3.0/settings.ini".force = true;
    "gtk-4.0/settings.ini".force = true;
    "gtk-4.0/gtk.css".force = true;
  };

  imports = [
    ./modules/packages.nix
    ./modules/git.nix
    ./modules/zsh.nix
    ./modules/starship.nix
    ./modules/emacs.nix
    ./modules/hyprland.nix
    ./modules/noctalia.nix
    ./modules/podman.nix
    ./modules/btop.nix
    ./modules/aliases.nix
    ./modules/nh.nix
    ./modules/easyeffects.nix
    ./modules/pi.nix
    ./modules/ghostty.nix
  ];
}
