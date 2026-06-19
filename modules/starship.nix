{ ... }:

{
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = { };
  };
  # Rosé Pine Dawn is the active prompt theme. Starship reads ~/.config/starship.toml
  # (its default + STARSHIP_CONFIG), so the live config lives at the XDG root; both
  # variants are mirrored under starship/ for `cp`-based dark switching:
  #   cp ~/.config/starship/rose-pine.toml ~/.config/starship.toml
  xdg.configFile."starship.toml".source = ../files/starship/rose-pine-dawn.toml;
  xdg.configFile."starship/rose-pine-dawn.toml".source = ../files/starship/rose-pine-dawn.toml;
  xdg.configFile."starship/rose-pine.toml".source = ../files/starship/rose-pine.toml;
}
