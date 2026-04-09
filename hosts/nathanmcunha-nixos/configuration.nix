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

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nixpkgs.config.allowUnfree = true;
  programs.nix-ld.enable = true;

  # Time zone
  time.timeZone = "America/Sao_Paulo";

  # Network
  networking.networkmanager.enable = true;
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

  # System packages
  environment.systemPackages = with pkgs; [
    vim
    git
    wget
    curl
    stow
    gh
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

  # OpenGL
  hardware.graphics.enable = true;
  hardware.graphics.extraPackages = with pkgs; [
    intel-media-driver
  ];

  hardware.enableRedistributableFirmware = true;

  system.stateVersion = "25.05";
}
