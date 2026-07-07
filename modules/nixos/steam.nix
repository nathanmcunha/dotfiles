{
  # Canonical owner of Steam system-level enablement. Installs steam
  # into environment.systemPackages and wires up 32-bit graphics,
  # hardware udev rules, and the FHS runtime Steam needs.
  programs.steam.enable = true;
  hardware.steam-hardware.enable = true;
}
