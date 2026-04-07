{ pkgs, ... }:

{
  # Symlink scripts to ~/.local/bin
  home.file.".local/bin/update-externals" = {
    source = ../files/scripts/update-externals.sh;
    executable = true;
  };

  home.file.".local/bin/setup-hermes-keys" = {
    source = ../files/scripts/setup-hermes-keys.sh;
    executable = true;
  };

  # Symlink versions file
  home.file.".config/home-manager/files/external/versions.json".source =
    ../files/external/versions.json;

  # Documentation
  home.file.".local/share/docs/PASS-GUIDE.md".source = ../files/docs/PASS-GUIDE.md;

  home.file.".local/share/docs/HERMES-GUIDE.md".source = ../files/docs/HERMES-GUIDE.md;

  home.file.".local/share/docs/SYSTEMD-MIGRATION.md".source = ../files/docs/SYSTEMD-MIGRATION.md;
}
