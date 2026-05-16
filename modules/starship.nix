{ config, ... }:

{
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    configPath = "${config.xdg.configHome}/starship/noctalia.toml";
    settings = {
      add_newline = true;
    };
  };
}
