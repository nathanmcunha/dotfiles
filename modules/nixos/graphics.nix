{ config, pkgs, ... }:

{
  hardware.graphics = {
    enable = true;
    # Required by 32-bit apps (Steam, Wine). Without it Steam's VGUI2
    # hits glXChooseVisual failed -> fatal assert.
    enable32Bit = true;
    extraPackages = with pkgs; [
      intel-compute-runtime
      intel-media-driver
      libva-vdpau-driver
      libvdpau-va-gl
    ];
  };
}
