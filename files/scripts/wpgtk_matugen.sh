#!/usr/bin/env bash

WALLPAPER="$1"

if [ -z "$WALLPAPER" ]; then
    WALLPAPER="$(wpg -c 2>/dev/null | head -1)"
fi

if [ -z "$WALLPAPER" ] || [ ! -f "$WALLPAPER" ]; then
    echo "No wallpaper provided and no current wpgtk wallpaper found"
    exit 1
fi

hour=$(date +%H)
if [ "$hour" -ge 17 ] || [ "$hour" -lt 6 ]; then
    MODE="dark"
else
    MODE="light"
fi

if [ "$MODE" = "dark" ]; then
    GTK_THEME="Gruvbox-Dark"
    ICON_THEME="oomox-Gruvbox-Dark"
    CURSOR_THEME="Bibata-Modern-Classic"
    PREFER_DARK="1"
else
    GTK_THEME="Gruvbox-Light"
    ICON_THEME="oomox-Gruvbox-Light"
    CURSOR_THEME="Bibata-Modern-Ice"
    PREFER_DARK="0"
fi

mkdir -p ~/.config/gtk-3.0 ~/.config/gtk-4.0 ~/.icons/default

for gtk_dir in gtk-3.0 gtk-4.0; do
    ini="$HOME/.config/$gtk_dir/settings.ini"
    if [ -f "$ini" ]; then
        sed -i "s/^gtk-theme-name=.*/gtk-theme-name=$GTK_THEME/" "$ini"
        sed -i "s/^gtk-icon-theme-name=.*/gtk-icon-theme-name=$ICON_THEME/" "$ini"
        sed -i "s/^gtk-cursor-theme-name=.*/gtk-cursor-theme-name=$CURSOR_THEME/" "$ini"
        sed -i "s/^gtk-application-prefer-dark-theme=.*/gtk-application-prefer-dark-theme=$PREFER_DARK/" "$ini"
    else
        printf '[Settings]\ngtk-theme-name=%s\ngtk-icon-theme-name=%s\ngtk-cursor-theme-name=%s\ngtk-application-prefer-dark-theme=%s\n' \
            "$GTK_THEME" "$ICON_THEME" "$CURSOR_THEME" "$PREFER_DARK" > "$ini"
    fi
done

printf '[Icon Theme]\nName=Default\nInherits=%s\n' "$CURSOR_THEME" > ~/.icons/default/index.theme

matugen image "$WALLPAPER" -m "$MODE" --source-color-index 0
