{ ... }:

{
  services.easyeffects.enable = true;

  # Start automatically at login. The upstream Home Manager module binds the
  # unit to graphical-session.target, which never activates under our
  # UWSM + Hyprland setup, so the service stays dead. Re-bind to
  # default.target (reached at user login; pipewire is socket-activated then).
  systemd.user.services.easyeffects.Install.WantedBy = [ "default.target" ];
}
