{ pkgs, ... }:

{
  programs.alacritty = {
    enable = true;

    settings = {
      general = {
        live_config_reload = true;
        import = [ "~/.config/alacritty/rose-pine-dawn.toml" ];
      };

      env.TERM = "alacritty";
      terminal.shell = {
        program = "${pkgs.zsh}/bin/zsh";
        args = [ "-l" ];
      };

      window = {
        padding = {
          x = 6;
          y = 6;
        };
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
        normal = {
          family = "Atkinson Hyperlegible Mono";
          style = "Regular";
        };
        bold = {
          family = "Atkinson Hyperlegible Mono";
          style = "Bold";
        };
        italic = {
          family = "Atkinson Hyperlegible Mono";
          style = "Italic";
        };
        offset = {
          x = 0;
          y = 2;
        };
      };
    };
  };

  xdg.configFile."alacritty/alacritty.toml".force = true;
  xdg.configFile."alacritty/rose-pine-dawn.toml".source = ../files/alacritty/rose-pine-dawn.toml;
  xdg.configFile."alacritty/rose-pine.toml".source = ../files/alacritty/rose-pine.toml;
}
