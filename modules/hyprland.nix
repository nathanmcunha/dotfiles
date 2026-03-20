{ ... }:

{
  home.file = {
    # Hypr configs
    ".config/hypr/hyprland.conf".source  = ../files/hypr/hyprland.conf;
    ".config/hypr/colors.conf".source    = ../files/hypr/colors.conf;
    ".config/hypr/hypridle.conf".source  = ../files/hypr/hypridle.conf;
    ".config/hypr/hyprlock.conf".source  = ../files/hypr/hyprlock.conf;
    ".config/hypr/hyprpaper.conf".source = ../files/hypr/hyprpaper.conf;
    ".config/hypr/rules.conf".source     = ../files/hypr/rules.conf;

    # Scripts (executable)
    ".config/hypr/scripts/screenshot.sh" = {
      source = ../files/hypr/scripts/screenshot.sh;
      executable = true;
    };
    ".config/hypr/scripts/wallpaper_rotate.sh" = {
      source = ../files/hypr/scripts/wallpaper_rotate.sh;
      executable = true;
    };

    # Hyprpanel
    ".config/hyprpanel/config.json".source = ../files/hyprpanel/config.json;

    # Walker
    ".config/walker/config.toml".source = ../files/walker/config.toml;

    # Matugen
    ".config/matugen/config.toml".source = ../files/matugen/config.toml;
    ".config/matugen/templates/hyprland-colors.conf".source = ../files/matugen/templates/hyprland-colors.conf;
    ".config/matugen/templates/wofi-style.css".source       = ../files/matugen/templates/wofi-style.css;
  };
}
