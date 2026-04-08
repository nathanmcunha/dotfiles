{
  home.username = "nathanmcunha";
  home.homeDirectory = "/home/nathanmcunha";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  imports = [
    ./modules/packages.nix
    ./modules/derivations.nix
    ./modules/git.nix
    ./modules/zsh.nix
    ./modules/starship.nix
    ./modules/emacs.nix
    ./modules/alacritty.nix
    ./modules/hyprland.nix
    ./modules/waybar.nix
    ./modules/wofi.nix
    ./modules/dunst.nix
    ./modules/podman.nix
    ./modules/claude.nix
    ./modules/external-tools.nix
    ./modules/hermes-agent.nix
    ./modules/btop.nix
    ./modules/aliases.nix
  ];
}
