{ config, pkgs, ... }:

{
  boot.loader = {
    systemd-boot = {
      enable = true;
      configurationLimit = 10;
    };
    efi.canTouchEfiVariables = true;
  };

  boot.loader.efi.efiSysMountPoint = "/boot";

  boot.kernelParams = [
    "quiet"
  ];
}
