{ pkgs, ... }:
{
  services.greetd.enable = true;
  services.greetd.settings.default_session.command =
    "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-session --sessions /run/current-system/sw/share/wayland-sessions";
  services.greetd.settings.default_session.user = "greeter";
  services.greetd.useTextGreeter = true;

  services.openssh.enable = true;

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  services.fstrim.enable = true;
}
