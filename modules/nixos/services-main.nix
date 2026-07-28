{ pkgs, ... }:
{
  services.greetd.enable = true;
  services.greetd.settings.default_session.command =
    "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-session --sessions /run/current-system/sw/share/wayland-sessions";
  services.greetd.settings.default_session.user = "greeter";
  services.greetd.useTextGreeter = true;

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
      AllowUsers = [ "nathanmcunha" ];
    };
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # Work around stale PID file + root-owned runtime dir after switch (avahi#5815).
  # ExecStartPre removes leftover PID and fixes ownership so the avahi user
  # (which drops privileges internally) can write to /run/avahi-daemon/.
  systemd.services.avahi-daemon.serviceConfig.ExecStartPre = [
    "${pkgs.writeShellScript "fix-avahi-run" ''
      rm -f /run/avahi-daemon/pid
      mkdir -p /run/avahi-daemon
      chown avahi:avahi /run/avahi-daemon
    ''}"
  ];

  services.fstrim.enable = true;
}
