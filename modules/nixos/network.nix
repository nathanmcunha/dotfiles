{ ... }:
{
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.backend = "iwd";
  networking.wireless.iwd.enable = true;
  networking.firewall.enable = true;
  networking.hostName = "nathanmcunha-nixos";


  programs.wireshark.enable = true;
}
