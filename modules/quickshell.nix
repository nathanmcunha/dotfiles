{ lib, ... }:

{
  # Quickshell QML files — entire directory tree symlinked recursively
  home.file.".config/hypr/scripts/quickshell" = {
    source = ../files/quickshell;
    recursive = true;
    force = true;
  };

  # Make all scripts executable after symlinking
  home.activation.quickshellPerms = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    find "$HOME/.config/hypr/scripts/quickshell" -name "*.sh" -exec chmod +x {} \;
    find "$HOME/.config/hypr/scripts/quickshell" -name "*.py" -exec chmod +x {} \;
  '';

  # Manager script and volume listener (under hypr/scripts, not quickshell/)
  home.file.".config/hypr/scripts/qs_manager.sh" = {
    source = ../files/hypr/scripts/qs_manager.sh;
    executable = true;
  };
  home.file.".config/hypr/scripts/volume_listener.sh" = {
    source = ../files/hypr/scripts/volume_listener.sh;
    executable = true;
  };

  # Matugen template for quickshell colors → generates /tmp/qs_colors.json
  home.file.".config/matugen/templates/qs-colors.json".source =
    ../files/quickshell/colors.json.template;
}
