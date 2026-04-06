#!/bin/bash

DIR="/home/nathanmcunha/Pictures/Wallpapers"
INTERVALO=6000

# Wait for swww daemon to be ready
for i in {1..10}; do
    swww query &>/dev/null && break
    sleep 0.5
done

first_run=true

while true; do
    WALLPAPER=$(find "$DIR" -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" | shuf -n 1)

    swww img "$WALLPAPER" --transition-type grow --transition-duration 2 --transition-fps 60

    matugen image "$WALLPAPER"

    if $first_run; then
        first_run=false
        sleep 1
    fi

    sleep $INTERVALO
done
