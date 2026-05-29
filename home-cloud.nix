{
  pkgs,
  lib,
  ...
}:

{
  home.username = "nathanmcunha";
  home.homeDirectory = "/home/nathanmcunha";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;
  programs.gpg.enable = true;
  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    enableZshIntegration = true;
    pinentry.package = pkgs.pinentry-curses;
    defaultCacheTtl = 28800;
    maxCacheTtl = 28800;
  };

  # Pi coding agent configuration
  programs.pi = {
    enable = true;

    defaultProvider = "kimi-coding";
    defaultModel = "kimi-for-coding";

    apiKeys = {
      kimi-coding = "!pass show kimi-coding/api-key";
      minimax = "!pass show minimax/api-key";
    };
    packages = [
      "https://github.com/mksglu/context-mode"
      "https://github.com/nicobailon/pi-subagents"
      "https://github.com/nicobailon/pi-web-access"
      "npm:@samfp/pi-memory"
    ];

    skills = [ ];

    skillsInputs = [ "superpowers" ];
  };

  imports = [
    ./modules/git.nix
    ./modules/zsh.nix
    ./modules/starship.nix
    ./modules/emacs.nix
    ./modules/podman.nix
    ./modules/btop.nix
    ./modules/aliases.nix
    ./modules/mise.nix
    ./modules/nh.nix
    ./modules/pi.nix
    ./modules/packages-cloud.nix
  ];

  # Override nix aliases to target cloud-vm
  home.shellAliases = lib.mkForce {
    hm = "home-manager switch --flake ~/dotfiles#cloud-vm";
    nixos = "sudo nixos-rebuild switch --flake ~/dotfiles#cloud-vm";
    nxfull = "nix flake update ~/dotfiles && sudo nixos-rebuild switch --flake ~/dotfiles#cloud-vm && home-manager switch --flake ~/dotfiles#cloud-vm";
  };
}
