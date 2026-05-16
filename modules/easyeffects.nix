{ pkgs, ... }:

{
  systemd.user.services.easyeffects = {
    Unit = {
      Description = "EasyEffects Audio Processing";
      After = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.easyeffects}/bin/easyeffects --gapplication-service";
      Restart = "on-failure";
      RestartSec = "2";
    };
  };
}