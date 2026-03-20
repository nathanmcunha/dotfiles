{ pkgs, ... }:

{
  home.packages = with pkgs; [
    emacs-nox
  ];

  # service disabled until we fix the config errors
  # services.emacs = {
  #   enable = true;
  #   startWithUserSession = true;
  # };
}
