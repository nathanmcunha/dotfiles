{ lib, ... }:

{
  home.file = {
    ".config/wpgtk/scripts/wpgtk_matugen.sh" = {
      source = ../files/scripts/wpgtk_matugen.sh;
      executable = true;
    };
  };

  home.activation.wpgtkInit = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        mkdir -p "$HOME/.config/wpgtk/scripts" 2>/dev/null || true

        if [ ! -f "$HOME/.config/wpgtk/wpg.conf" ]; then
          cat > "$HOME/.config/wpgtk/wpg.conf" <<'EOF'
    [settings]
    col = 16
    light_theme = False
    editor = vim
    execute_cmd = True
    command = ~/.config/wpgtk/scripts/wpgtk_matugen.sh
    active = 0
    EOF
        fi
  '';
}
