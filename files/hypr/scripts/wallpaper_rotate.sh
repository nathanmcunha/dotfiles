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

current_mode=$(get_mode)

while true; do
    new_mode=$(get_mode)

    if [ "$new_mode" != "$current_mode" ]; then
        current_mode="$new_mode"
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
