{ config, pkgs, ... }:

{
  # Dconf
  programs.dconf.enable = true;

  # DBus
  services.dbus = {
    enable = true;
    implementation = "broker";
  };

  # File indexing
  services.locate.enable = true;

  # MPD
  services.mpd.enable = false;

  # Tumbler removed - depends on Thunar which is now user-level
  # Firmware updates
  services.fwupd.enable = true;

  # Flatpak
  services.flatpak.enable = true;

}
