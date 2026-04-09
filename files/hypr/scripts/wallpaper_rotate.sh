#!/usr/bin/env bash

BASE_DIR="/home/nathanmcunha/Pictures/Wallpapers/gruvbox/wallpapers"
INTERVALO=6000

for i in {1..10}; do
    awww query &>/dev/null && break
    sleep 0.5
done

first_run=true

get_mode() {
    local hour
    hour=$(date +%H)
    if [ "$hour" -ge 17 ] || [ "$hour" -lt 6 ]; then
        echo "dark"
    else
        echo "light"
    fi
}

get_dir() {
    echo "$BASE_DIR/$(get_mode)"
}

switch_gtk_theme() {
    local mode="$1"
    if [ "$mode" = "dark" ]; then
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
}

current_mode=$(get_mode)
switch_gtk_theme "$current_mode"

while true; do
    new_mode=$(get_mode)

    if [ "$new_mode" != "$current_mode" ]; then
        current_mode="$new_mode"
        switch_gtk_theme "$current_mode"
    fi

    DIR=$(get_dir)
    WALLPAPER=$(find "$DIR" -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" \) | shuf -n 1)

    if [ -z "$WALLPAPER" ]; then
        sleep 30
        continue
    fi

    matugen image "$WALLPAPER" -m "$current_mode" --source-color-index 0

    if $first_run; then
        first_run=false
        sleep 1
    fi

    sleep $INTERVALO
done
