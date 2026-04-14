{ pkgs, ... }:
{
  home.packages = [ pkgs.claude-code-router ];
  programs.claude-code-router = {
    enable = true;
  };
}
