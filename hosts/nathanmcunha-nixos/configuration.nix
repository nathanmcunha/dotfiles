{
  config,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/hardware.nix
    ../../modules/nixos/hyprland.nix
    ../../modules/nixos/boot.nix
    ../../modules/nixos/services.nix
  ];

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
    trusted-users = [ "root" "nathanmcunha" ];
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  nixpkgs.config.allowUnfree = true;
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc
      zlib
      fuse3
      icu
      nss
      openssl
      curl
      expat
    ];
  };

  # Time zone
  time.timeZone = "America/Sao_Paulo";

  # Network
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.backend = "iwd";
  networking.wireless.iwd.enable = true;
  networking.wireless.enable = pkgs.lib.mkForce false;
  networking.hostName = "nathanmcunha-nixos";
  # i18n
  i18n.defaultLocale = "en_US.UTF-8";

  # Console font
  console.font = "ter-v16n";

  # Services
  services.greetd.enable = true;
  services.greetd.settings.default_session.command =
    "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-session --sessions /run/current-system/sw/share/wayland-sessions";
  services.greetd.settings.default_session.user = "greeter";
  services.greetd.useTextGreeter = true;

  programs.zsh.enable = true;

  # Fstrim
  services.fstrim.enable = true;

  # Fonts
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-color-emoji
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    nerd-fonts.symbols-only
  ];

  # System packages (keep only rescue/TTY essentials)
  environment.systemPackages = with pkgs; [
    vim
    git
    wget
    curl
    stow
    impala
  ];

  # Users
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
    ];
  };

  users.groups.nathanmcunha = { };

  # Sound
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  # Bluetooth
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  #Hardware & Devices(Udev)
  services.udev.packages = with pkgs; [
    vial
  ];

  hardware.enableRedistributableFirmware = true;

  system.stateVersion = "25.05";
}
