{ pkgs, lib, ... }:

{
  systemd.user.services = {
    awww-daemon = {
      Unit = {
        Description = "Wallpaper Daemon (awww)";
        After = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.awww}/bin/awww-daemon";
        Restart = "on-failure";
        RestartSec = "2";
      };
    };

    wallpaper-rotate = {
      Unit = {
        Description = "Rotate wallpaper and regenerate matugen colors";
      };
      Service = {
        ExecStart = "%h/.config/hypr/scripts/wallpaper_rotate.sh";
        Restart = "on-failure";
        RestartSec = "3";
      };
    };

    hypridle = {
      Unit = {
        Description = "Hypridle idle daemon";
        After = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "/usr/local/bin/hypridle";
        Restart = "on-failure";
        RestartSec = "2";
      };
    };

    hyprpolkitagent = {
      Unit = {
        Description = "Hyprland polkit authentication agent";
        After = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "/usr/local/bin/hyprpolkitagent";
        Restart = "on-failure";
        RestartSec = "2";
      };
    };

    cliphist-text = {
      Unit = {
        Description = "Clipboard history (text)";
        After = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "/usr/bin/wl-paste --type text --watch /usr/bin/cliphist store";
        Restart = "on-failure";
        RestartSec = "2";
      };
    };

    cliphist-image = {
      Unit = {
        Description = "Clipboard history (images)";
        After = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "/usr/bin/wl-paste --type image --watch /usr/bin/cliphist store";
        Restart = "on-failure";
        RestartSec = "2";
      };
    };

    playerctld = {
      Unit = {
        Description = "Playerctl daemon for media control";
        After = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "/usr/bin/playerctld";
        Restart = "on-failure";
        RestartSec = "2";
      };
    };

    volume-listener = {
      Unit = {
        Description = "Volume change listener for Quickshell";
        After = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "%h/.config/hypr/scripts/volume_listener.sh";
        Restart = "on-failure";
        RestartSec = "2";
      };
    };

    copyq = {
      Unit = {
        Description = "CopyQ clipboard manager";
        After = [ "graphical-session.target" ];
      };
      Service = {
        Type = "forking";
        ExecStart = "/usr/bin/copyq --start-server";
        Restart = "on-failure";
        RestartSec = "2";
      };
    };

    elephant = {
      Unit = {
        Description = "Elephant";
        After = [ "graphical-session.target" ];
      };
      Service = {
        Environment = "LD_LIBRARY_PATH=%h/.local/lib64";
        ExecStart = "%h/.local/bin/elephant";
        Restart = "on-failure";
        RestartSec = "2";
      };
    };
  };

  home.file = {
    ".config/hypr/hyprland.conf".source = ../files/hypr/hyprland.conf;
    ".config/hypr/hypridle.conf".source = ../files/hypr/hypridle.conf;
    ".config/hypr/hyprlock.conf".source = ../files/hypr/hyprlock.conf;
    ".config/hypr/rules.conf".source = ../files/hypr/rules.conf;
    ".config/hypr/colors.conf" = {
      source = ../files/hypr/colors.conf;
      force = true;
    };

    ".config/hypr/scripts/screenshot.sh" = {
      source = ../files/hypr/scripts/screenshot.sh;
      executable = true;
    };
    ".config/hypr/scripts/wallpaper_rotate.sh" = {
      source = ../files/hypr/scripts/wallpaper_rotate.sh;
      executable = true;
    };
    ".config/hypr/scripts/volume_listener.sh" = {
      source = ../files/hypr/scripts/volume_listener.sh;
      executable = true;
    };
    ".config/hypr/scripts/qs_manager.sh" = {
      source = ../files/hypr/scripts/qs_manager.sh;
      executable = true;
    };

    ".config/matugen/config.toml".source = ../files/matugen/config.toml;
    ".config/matugen/templates/hyprland-colors.conf".source =
      ../files/matugen/templates/hyprland-colors.conf;
    ".config/matugen/templates/wofi-style.css".source =
      ../files/matugen/templates/wofi-style.css;
    ".config/matugen/templates/waybar-colors.css".source =
      ../files/matugen/templates/waybar-colors.css;
    ".config/matugen/templates/dunstrc".source =
      ../files/matugen/templates/dunstrc;
    ".config/matugen/templates/qs-colors.json".source =
      ../files/matugen/templates/qs-colors.json;
  };

  home.activation.makeMatugenTargetsWritable =
    let
      colorFiles = [
        ".config/hypr/colors.conf"
        ".config/dunst/dunstrc"
      ];
      scriptLines = map (
        f: ''
          if [ -L "$HOME/${f}" ]; then
            cp --remove-destination "$(readlink -f "$HOME/${f}")" "$HOME/${f}"
            chmod u+w "$HOME/${f}"
          fi
        ''
      ) colorFiles;
    in
    lib.hm.dag.entryAfter [ "writeBoundary" ] (builtins.concatStringsSep "\n" scriptLines);
}
