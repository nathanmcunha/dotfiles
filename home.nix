{ pkgs, lib, inputs, ... }:

{
  home.username = "nathanmcunha";
  home.homeDirectory = "/home/nathanmcunha";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;
  programs.gpg.enable = true;

  services.gpg-agent = {
    enable = true;
    enableZshIntegration = true;
    pinentry.package = pkgs.pinentry-curses;
    defaultCacheTtl = 3600;
    maxCacheTtl = 28800;
  };

  gtk = {
    enable = true;
    theme = {
      name = "Gruvbox-Dark";
      package = null;
    };
    gtk4.theme = {
      name = "Gruvbox-Dark";
      package = null;
    };
    iconTheme = {
      name = "oomox-Gruvbox-Dark";
      package = null;
    };
    cursorTheme = {
      name = "Bibata-Modern-Classic";
      package = pkgs.bibata-cursors;
    };
  };

  xdg.configFile."gtk-3.0/settings.ini".force = true;
  xdg.configFile."gtk-4.0/settings.ini".force = true;

  home.activation.installThemeAssets = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    export PATH="${pkgs.gzip}/bin:$PATH"
    mkdir -p "$HOME/.themes" "$HOME/.icons"

    ${pkgs.gnutar}/bin/tar xzf ${./files/assets/gtk-theme-gruvbox-dark.tar.gz} -C "$HOME/.themes"
    ${pkgs.gnutar}/bin/tar xzf ${./files/assets/gtk-theme-gruvbox-light.tar.gz} -C "$HOME/.themes"
    ${pkgs.gnutar}/bin/tar xzf ${./files/assets/icons-gruvbox-dark.tar.gz} -C "$HOME/.icons"
    ${pkgs.gnutar}/bin/tar xzf ${./files/assets/icons-gruvbox-light.tar.gz} -C "$HOME/.icons"

    mkdir -p "$HOME/.icons/default"
    printf '[Icon Theme]\nName=Default\nInherits=Bibata-Modern-Classic\n' > "$HOME/.icons/default/index.theme"
  '';

  imports = [
    ./modules/packages.nix
    ./modules/derivations.nix
    ./modules/git.nix
    ./modules/zsh.nix
    ./modules/starship.nix
    ./modules/emacs.nix
    ./modules/alacritty.nix
    ./modules/hyprland.nix
    ./modules/waybar.nix
    ./modules/wofi.nix
    ./modules/dunst.nix
    ./modules/wpgtk.nix
    ./modules/podman.nix
    ./modules/claude.nix
    ./modules/external-tools.nix
    ./modules/btop.nix
    ./modules/aliases.nix
    ./modules/mise.nix
    ./modules/hermes-agent.nix
  ];
}
