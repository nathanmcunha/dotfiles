#!/usr/bin/env bash

DIR="/home/nathanmcunha/Pictures/Wallpapers/gruvbox/wallpapers"
INTERVALO=6000

for i in {1..10}; do
    awww query &>/dev/null && break
    sleep 0.5
done

first_run=true

while true; do
    WALLPAPER=$(find "$DIR" -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" \) | shuf -n 1)

    if [ -z "$WALLPAPER" ]; then
        sleep 30
        continue
    fi

    matugen image "$WALLPAPER" -m dark --source-color-index 0

    if $first_run; then
        first_run=false
        sleep 1
    fi

    sleep $INTERVALO
done
