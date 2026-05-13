{ config, pkgs, ... }: {
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
      "docker"
      "lpadmin"
    ];
  };

  users.groups.nathanmcunha = { };
}
