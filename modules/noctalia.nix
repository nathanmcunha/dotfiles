{
  pkgs,
  inputs,
  lib,
  ...
}:

{
  imports = [ inputs.noctalia.homeModules.default ];

  programs.noctalia-shell = {
    enable = true;
    package = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;
    settings = ../files/noctalia/settings.json;
    plugins = ../files/noctalia/plugins.json;

    user-templates = {
      templates = {
        hyprland = {
          input_path = "~/.config/noctalia/templates/hyprland-colors.conf";
          output_path = "~/.config/hypr/colors.conf";
          post_hook = "hyprctl reload";
        };
        wofi = {
          input_path = "~/.config/noctalia/templates/wofi-style.css";
          output_path = "~/.config/wofi/style.css";
        };
        dunst = {
          input_path = "~/.config/noctalia/templates/dunstrc";
          output_path = "~/.config/dunst/dunstrc";
          post_hook = "pkill dunst; dunst &";
        };
        alacritty = {
          input_path = "~/.config/noctalia/templates/alacritty-colors.toml";
          output_path = "~/.config/alacritty/theme-colors.toml";
        };
      };
    };
  };

  home.packages = with pkgs; [
    # dependencies required by noctalia plugins and features
    gpu-screen-recorder
    (tesseract.override {
      enableLanguages = [ "eng" ];
    })
    zbar
    translate-shell
    gifski
    wl-mirror
  ];

  home.activation.setAdwGtk3Theme = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if command -v gsettings >/dev/null 2>&1; then
      gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3' 2>/dev/null || true
    fi
  '';

  home.file = {
    ".config/noctalia/templates/hyprland-colors.conf".source =
      ../files/noctalia/templates/hyprland-colors.conf;
    ".config/noctalia/templates/wofi-style.css".source =
      ../files/noctalia/templates/wofi-style.css;
    ".config/noctalia/templates/dunstrc".source =
      ../files/noctalia/templates/dunstrc;
    ".config/noctalia/templates/alacritty-colors.toml".source =
      ../files/noctalia/templates/alacritty-colors.toml;
  };
}
