{ config, pkgs, ... }:

{
  # Intel GPU
  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      vaapiIntel
      vaapiVdpau
      libvdpau-va-gl
    ];
  };

  # Intel WiFi
  hardware.enableRedistributableFirmware = true;
  networking.wireless.enable = false;  # Use NetworkManager

  # Intel Audio
  sound.enable = true;

  # Bluetooth
  hardware.bluetooth.enable = true;
}