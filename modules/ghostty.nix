{ pkgs, ... }:

{
  programs.ghostty = {
    enable = true;

    # Package selection — ghostty is available in nixpkgs unstable
    package = pkgs.ghostty;

    settings = {
      # =========================================================================
      # Font
      # =========================================================================
      font-family = "Atkinson Hyperlegible Mono";
      font-size = 12;

      # =========================================================================
      # Theme — Rosé Pine (https://github.com/rose-pine/ghostty)
      # Variants shipped under files/ghostty/themes/. Switch between them:
      #   "rose-pine"      — dark
      #   "rose-pine-dawn" — light
      #   "rose-pine-moon" — dark (duskier)
      # =========================================================================
      theme = "rose-pine-dawn";

      # =========================================================================
      # Window
      # =========================================================================
      window-padding-x = 6;
      window-padding-y = 6;
      background-opacity = 0.99;
      title = "Ghostty";
      window-decoration = true;

      # =========================================================================
      # Terminal
      # =========================================================================
      shell-integration = "zsh";
      copy-on-select = "clipboard";
      confirm-close-surface = false;

      # =========================================================================
      # Cursor
      # =========================================================================
      cursor-style = "bar";
      cursor-style-blink = true;

      # =========================================================================
      # Scrollback
      # =========================================================================
      scrollback-limit = 10000;

      # =========================================================================
      # Mouse
      # =========================================================================
      mouse-hide-while-typing = true;
    };

    # Install Ghostty's Vim syntax file for config highlighting
    installVimSyntax = true;
  };

  # Rosé Pine theme variants — symlinked so Ghostty can load them by name.
  # Active theme is set via `theme = "rose-pine-dawn"` above.
  # To switch variants on the fly without a rebuild, symlink the desired one
  # to ~/.config/ghostty/theme and update the setting.
  xdg.configFile."ghostty/themes/rose-pine".source = ../files/ghostty/themes/rose-pine;
  xdg.configFile."ghostty/themes/rose-pine-dawn".source = ../files/ghostty/themes/rose-pine-dawn;
  xdg.configFile."ghostty/themes/rose-pine-moon".source = ../files/ghostty/themes/rose-pine-moon;
}
