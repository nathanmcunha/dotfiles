#!/usr/bin/env bash

WALLPAPER="$1"

if [ -z "$WALLPAPER" ]; then
    WALLPAPER="$(wpg -c 2>/dev/null | head -1)"
fi

if [ -z "$WALLPAPER" ] || [ ! -f "$WALLPAPER" ]; then
    echo "No wallpaper provided and no current wpgtk wallpaper found"
    exit 1
fi

matugen image "$WALLPAPER" -m dark --source-color-index 0
