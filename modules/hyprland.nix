{ pkgs, lib, ... }:

{
  systemd.user.services = {
    hypridle = {
      Unit = {
        Description = "Hypridle idle daemon";
        After = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.hypridle}/bin/hypridle";
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
        ExecStart = "${pkgs.hyprpolkitagent}/bin/hyprpolkitagent";
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
        ExecStart = "${pkgs.playerctl}/bin/playerctld";
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

  };

  home.sessionVariables = {
    QT_QPA_PLATFORMTHEME = "qt6ct";
  };


}
