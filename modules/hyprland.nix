{ lib, ... }:

{
  # HyprPanel writes back to its config at runtime, so it cannot be a read-only
  # Nix symlink. Copy it on activation instead; re-applying HM will refresh it.
  home.activation.copyHyprpanelConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD install -Dm644 ${../files/hyprpanel/config.json} "$HOME/.config/hyprpanel/config.json"
  '';

  # All Wayland daemons are managed as systemd user services rather than bare
  # exec-once binaries. Benefits: automatic restart on failure, proper dependency
  # ordering, and logs accessible via `journalctl --user -u <service>`.
  #
  # None use WantedBy=graphical-session.target because WAYLAND_DISPLAY must be
  # imported by Hyprland first. They are triggered from hyprland.conf instead.
  systemd.user.services = {
    hyprpanel = {
      Unit = {
        Description = "HyprPanel status bar";
        After = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "/usr/local/bin/hyprpanel-wrapper";
        Restart = "on-failure";
        RestartSec = "2";
      };
    };

    hyprpaper = {
      Unit = {
        Description = "Hyprpaper wallpaper daemon";
        After = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "/usr/local/bin/hyprpaper";
        Restart = "on-failure";
        RestartSec = "2";
      };
    };

    wallpaper-rotate = {
      Unit = {
        Description = "Rotate wallpaper and regenerate matugen colors";
        # hyprpaper must be ready before the script can set a wallpaper
        After = [ "hyprpaper.service" ];
        Requires = [ "hyprpaper.service" ];
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

    copyq = {
      Unit = {
        Description = "CopyQ clipboard manager";
        After = [ "graphical-session.target" ];
      };
      Service = {
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
    # Hypr configs
    ".config/hypr/hyprland.conf".source  = ../files/hypr/hyprland.conf;
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

    # Walker
    ".config/walker/config.toml".source = ../files/walker/config.toml;

    # Matugen
    ".config/matugen/config.toml".source = ../files/matugen/config.toml;
    ".config/matugen/templates/hyprland-colors.conf".source = ../files/matugen/templates/hyprland-colors.conf;
    ".config/matugen/templates/wofi-style.css".source       = ../files/matugen/templates/wofi-style.css;
  };
}
