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
  };

  home.file = {
    ".config/hypr/hyprland.conf".source = ../files/hypr/hyprland.conf;
    ".config/hypr/hypridle.conf".source = ../files/hypr/hypridle.conf;
    ".config/hypr/rules.conf".source = ../files/hypr/rules.conf;
    ".config/hypr/scripts/screenshot.sh" = {
      source = ../files/hypr/scripts/screenshot.sh;
      executable = true;
    };

  };

  home.sessionVariables = {
    QT_QPA_PLATFORMTHEME = "qt6ct";
  };


}
