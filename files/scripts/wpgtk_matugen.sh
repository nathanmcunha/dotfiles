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

matugen image "$WALLPAPER" -m "$MODE" --source-color-index 0
