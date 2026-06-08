{ ... }:

{
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      scan_timeout = 2000;
      command_timeout = 2000;
    };
  };
}
