{ pkgs, ... }:

{
  programs.alacritty = {
    enable = true;

    settings = {
      general = {
        live_config_reload = true;
        import = [ "~/.config/alacritty/theme-colors.toml" ];
      };

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
    };
  };
}
