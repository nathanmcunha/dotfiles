#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="/home/nathanmcunha/Pictures/Wallpapers/gruvbox/wallpapers"
CHECK_INTERVAL=60          # Check theme every 60 seconds
WALLPAPER_INTERVAL=30      # Change wallpaper every 30 checks (~30 min)

# Wait for awww to be ready
for i in {1..20}; do
    if awww query &>/dev/null; then
        break
    fi
    sleep 0.5
done

first_run=true
wallpaper_counter=0
current_mode=""

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
    local GTK_THEME ICON_THEME CURSOR_THEME PREFER_DARK

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
        cat > "$HOME/.config/$gtk_dir/settings.ini" <<EOF
[Settings]
gtk-theme-name=$GTK_THEME
gtk-icon-theme-name=$ICON_THEME
gtk-cursor-theme-name=$CURSOR_THEME
gtk-application-prefer-dark-theme=$PREFER_DARK
gtk-font-name=JetBrainsMono Nerd Font Regular 11
gtk-xft-antialias=1
gtk-xft-hinting=1
gtk-xft-hintstyle=hintslight
gtk-xft-rgba=rgb
EOF
    done

    printf '[Icon Theme]\nName=Default\nInherits=%s\n' "$CURSOR_THEME" > ~/.icons/default/index.theme
}

while true; do
    new_mode=$(get_mode)

    # Switch GTK theme immediately when the hour changes
    if [ "$new_mode" != "$current_mode" ]; then
        current_mode="$new_mode"
        switch_gtk_theme "$current_mode"
    fi

    wallpaper_counter=$((wallpaper_counter + 1))

    # Change wallpaper on first run or every N iterations
    if $first_run || [ "$wallpaper_counter" -ge "$WALLPAPER_INTERVAL" ]; then
        first_run=false
        wallpaper_counter=0

        DIR=$(get_dir)
        WALLPAPER=$(find "$DIR" -maxdepth 1 -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" \) | shuf -n 1)

        if [ -n "$WALLPAPER" ]; then
            matugen image "$WALLPAPER" -m "$current_mode" --source-color-index 0 || true
        fi
    fi

    sleep "$CHECK_INTERVAL"
done
