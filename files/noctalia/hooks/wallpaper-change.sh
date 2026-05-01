#!/usr/bin/env bash
set -euo pipefail

# Noctalia may pass the wallpaper path as $1
WALLPAPER="${1:-}"

# Fallback: try awww query if available
if [ -z "$WALLPAPER" ]; then
    if command -v awww >/dev/null 2>&1; then
        WALLPAPER=$(awww query 2>/dev/null | head -1) || true
    fi
fi

if [ -z "$WALLPAPER" ] || [ ! -f "$WALLPAPER" ]; then
    echo "wallpaper-change: no wallpaper path provided, skipping matugen"
    exit 0
fi

# Determine mode from current time (same logic as old wallpaper_rotate.sh)
hour=$(date +%H)
if [ "$hour" -ge 17 ] || [ "$hour" -lt 6 ]; then
    MODE="dark"
else
    MODE="light"
fi

matugen image "$WALLPAPER" -m "$MODE" --source-color-index 0 || true
