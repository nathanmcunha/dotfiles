{ config, pkgs, ... }:

{
  boot.loader = {
    systemd-boot = {
      enable = true;
      configurationLimit = 10;
      extraEntries."windows.conf" = ''
        title Windows Boot Manager
        efi /EFI/Microsoft/Boot/bootmgfw.efi
        sort-key o_windows
      '';
    };
    efi.canTouchEfiVariables = true;
  };

  boot.loader.efi.efiSysMountPoint = "/boot";

  boot.kernelPackages = pkgs.linuxPackages_6_12;

  boot.kernelParams = [
    "quiet"
  ];
}
