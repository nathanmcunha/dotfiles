{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/hyprland.nix
    ../../modules/nixos/boot.nix
    ../../modules/nixos/services.nix
    ../../modules/nixos/nix.nix
    ../../modules/nixos/fonts.nix
    ../../modules/nixos/network.nix
    ../../modules/nixos/services-main.nix
    ../../modules/nixos/users.nix
    ../../modules/nixos/audio.nix
    ../../modules/nixos/bluetooth.nix
    ../../modules/nixos/udev.nix
    ../../modules/nixos/graphics.nix
  ];

  nixpkgs.config.allowUnfree = true;
  time.timeZone = "America/Sao_Paulo";
  i18n.defaultLocale = "en_US.UTF-8";
  console.font = "ter-v16n";

  environment.systemPackages = with pkgs; [ vim wget curl stow ];

  hardware.enableRedistributableFirmware = true;
  system.stateVersion = "25.05";
}
