{ config, pkgs, ... }:
{
  programs.zsh.enable = true;

  users.users.nathanmcunha = {
    isNormalUser = true;
    group = "nathanmcunha";
    shell = pkgs.zsh;
    extraGroups = [
      "wheel"
      "input"
      "networkmanager"
      "audio"
      "video"
      "bluetooth"
      "scanner"
      "wireshark"
    ];
  };

  users.groups.nathanmcunha = { };
}
