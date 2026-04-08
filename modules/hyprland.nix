{ pkgs, ... }:

{
  # All Wayland daemons are managed as systemd user services rather than bare
  # exec-once binaries. Benefits: automatic restart on failure, proper dependency
  # ordering, and logs accessible via `journalctl --user -u <service>`.
  #
  # None use WantedBy=graphical-session.target because WAYLAND_DISPLAY must be
  # imported by Hyprland first. They are triggered from hyprland.conf instead.
  systemd.user.services = {
    # Wallpaper management
    swww-daemon = {
      Unit = {
        Description = "Simple Wallpaper Daemon (swww)";
        After = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "/usr/bin/swww-daemon";
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

    # Hyprland components
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

    # Clipboard management
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

    # Media player
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

    # Volume monitoring
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

    # Clipboard manager
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

    # Auxiliary app
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
    # Hypr configs
    ".config/hypr/hyprland.conf".source = ../files/hypr/hyprland.conf;
    ".config/hypr/hypridle.conf".source = ../files/hypr/hypridle.conf;
    ".config/hypr/hyprlock.conf".source = ../files/hypr/hyprlock.conf;
    ".config/hypr/rules.conf".source = ../files/hypr/rules.conf;
    ".config/hypr/colors.conf".source = ../files/hypr/colors.conf;

    # Scripts (executable)
    ".config/hypr/scripts/screenshot.sh" = {
      source = ../files/hypr/scripts/screenshot.sh;
      executable = true;
    };
    ".config/hypr/scripts/wallpaper_rotate.sh" = {
      source = ../files/hypr/scripts/wallpaper_rotate.sh;
      executable = true;
    };

    # Matugen
    ".config/matugen/config.toml".source = ../files/matugen/config.toml;
    ".config/matugen/templates/hyprland-colors.conf".source =
      ../files/matugen/templates/hyprland-colors.conf;
    ".config/matugen/templates/wofi-style.css".source = ../files/matugen/templates/wofi-style.css;
  };
}
