{ config, pkgs, ... }:

{
  # Intel GPU
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-vaapi-driver
      libva-vdpau-driver
      libvdpau-va-gl
    ];
  };

  # Intel WiFi
#  hardware.enableRedistributableFirmware = true;
#  networking.wireless.enable = false;  # Use NetworkManager

  # Intel Audio
#  sound.enable = true;

  # Bluetooth
#  hardware.bluetooth.enable = true;
}
