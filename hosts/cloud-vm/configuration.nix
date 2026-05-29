{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/nix.nix
  ];

  nixpkgs.config.allowUnfree = true;
  time.timeZone = "America/Sao_Paulo";
  i18n.defaultLocale = "en_US.UTF-8";

  # User (headless — no audio/video/bluetooth/wireshark groups)
  programs.zsh.enable = true;
  users.users.nathanmcunha = {
    isNormalUser = true;
    group = "nathanmcunha";
    shell = pkgs.zsh;
    extraGroups = [
      "wheel"
      "networkmanager"
      "docker"
    ];
    openssh.authorizedKeys.keys = [
      # TODO: add your public key here
    ];
  };
  users.groups.nathanmcunha = { };

  # Networking — DHCP only, no wifi/NetworkManager
  networking.hostName = "cloud-vm";
  networking.networkmanager.enable = false;
  networking.useDHCP = true;

  # SSH with key-based auth
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # Bootloader — GRUB for max cloud provider compatibility
  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
  };

  environment.systemPackages = with pkgs; [
    vim
    wget
    curl
  ];

  system.stateVersion = "25.05";
}
