{ lib, ... }:

{
  home.file.".config/waybar" = {
    source = ../files/waybar;
    recursive = true;
    force = true;
  };

  home.activation.waybarPerms = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    find "$HOME/.config/waybar" -name "*.sh" -exec chmod +x {} \;
  '';
}
