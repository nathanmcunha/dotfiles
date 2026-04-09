{ lib, ... }:

{
  home.file.".config/waybar" = {
    source = ../files/waybar;
    recursive = true;
    force = true;
  };

  home.activation.waybarPerms = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    find "$HOME/.config/waybar" -name "*.sh" -exec chmod +x {} \;

    if [ -L "$HOME/.config/waybar/colors.css" ]; then
      cp --remove-destination "$(readlink -f "$HOME/.config/waybar/colors.css")" "$HOME/.config/waybar/colors.css"
      chmod u+w "$HOME/.config/waybar/colors.css"
    fi
  '';
}
