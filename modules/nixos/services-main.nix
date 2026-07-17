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

  # Work around stale PID file left behind after switch (avahi#5815).
  # The old process exits but /run/avahi-daemon/pid persists; the new
  # daemon's O_EXCL open then fails with "File exists".
  systemd.services.avahi-daemon.serviceConfig.ExecStartPre = [
    "-${pkgs.coreutils}/bin/rm -f /run/avahi-daemon/pid"
  ];

  services.fstrim.enable = true;
}
