{ pkgs, ... }:

{
  # Symlink the update script to ~/.local/bin
  home.file.".local/bin/update-externals" = {
    source = ../files/scripts/update-externals.sh;
    executable = true;
  };

  # Symlink versions file
  home.file.".config/home-manager/files/external/versions.json".source =
    ../files/external/versions.json;
}
