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

  # Tumbler removed - depends on Thunar which is now user-level
  # Firmware updates
  services.fwupd.enable = true;

  # Flatpak
  services.flatpak.enable = true;

  # Printing (CUPS) + Brother + HP drivers
  services.printing = {
    enable = true;
    drivers = with pkgs; [
      hplip
      brlaser              # Open-source Brother laser driver (fallback)
      brgenml1lpr          # Brother generic LPR driver
      brgenml1cupswrapper  # Brother generic CUPS wrapper
    ];
  };

  # Scanner — SANE with Brother brscan4 backend
  hardware.sane = {
    enable = true;
    brscan4.enable = true;
  };

  programs.kdeconnect.enable = true;

}
