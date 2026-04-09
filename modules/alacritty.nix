{ pkgs, ... }:

{
  programs.alacritty = {
    enable = true;

    settings = {
      general.live_config_reload = true;

      env.TERM = "alacritty";
      terminal.shell = {
        program = "${pkgs.zsh}/bin/zsh";
        args = [ "-l" ];
      };

      window = {
        padding = { x = 10; y = 10; };
        opacity = 0.99;
        title = "Alacritty";
        decorations = "Full";
      };

      scrolling = {
        history = 10000;
        multiplier = 3;
      };

      font = {
        size = 12.0;
        normal = { family = "JetBrainsMono Nerd Font"; style = "Regular"; };
        bold   = { family = "JetBrainsMono Nerd Font"; style = "Bold"; };
        italic = { family = "JetBrainsMono Nerd Font"; style = "Italic"; };
      };

      colors = {
        primary = {
          background = "#fdf6e3";
          foreground = "#586e75";
        };
        normal = {
          black   = "#073642";
          red     = "#dc322f";
          green   = "#859900";
          yellow  = "#b58900";
          blue    = "#268bd2";
          magenta = "#d33682";
          cyan    = "#2aa198";
          white   = "#eee8d5";
        };
        bright = {
          black   = "#002b36";
          red     = "#cb4b16";
          green   = "#586e75";
          yellow  = "#657b83";
          blue    = "#839496";
          magenta = "#6c71c4";
          cyan    = "#93a1a1";
          white   = "#eee8d5";
        };
      };
    };
  };
}
