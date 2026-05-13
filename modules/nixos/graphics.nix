{ config, pkgs, ... }:

{
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-compute-runtime
      intel-media-driver
      libva-vdpau-driver
      libvdpau-va-gl
    ];
  };
}
