{ pkgs, ... }:

{
  programs.mise = {
    enable = true;
    enableZshIntegration = true;

    settings = {
      # Use precompiled binaries instead of compiling from source
      all_compile = false;

      # Only activate in directories with a .mise.toml
      activate_aggressive = false;
      not_found_auto_install = false;
    };

    # No global tools — project-level only
    # globalConfig = {
    #   tools = { };
    # };
  };
}
