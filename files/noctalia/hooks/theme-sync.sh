#!/usr/bin/env bash
set -euo pipefail

# Unified theme sync hook for Noctalia.
# Called by wallpaperChange, darkModeChange, and colorGeneration hooks.
# Ensures matugen + GTK + Alacritty stay in sync with the current
# wallpaper and time-of-day mode (dark 17:00-05:59, light 06:00-16:59).

BASE_DIR="/home/nathanmcunha/Pictures/Wallpapers/gruvbox/wallpapers"
MODE=""
WALLPAPER=""

# Noctalia may pass wallpaper path and/or mode as arguments
for arg in "$@"; do
    if [ "$arg" = "dark" ] || [ "$arg" = "light" ]; then
        MODE="$arg"
    elif [ -f "$arg" ]; then
        WALLPAPER="$arg"
    fi
done

# Fallback mode from current time
if [ -z "$MODE" ]; then
    hour=$(date +%H)
    if [ "$hour" -ge 17 ] || [ "$hour" -lt 6 ]; then
        MODE="dark"
    else
        MODE="light"
    fi
fi

# Pick a wallpaper from the correct dark/light subdirectory when:
# - no wallpaper was passed (darkModeChange / colorGeneration)
# - the passed wallpaper is from the wrong subdirectory
CORRECT_DIR="$BASE_DIR/$MODE"
if [ -z "$WALLPAPER" ] || [[ "$WALLPAPER" != "$CORRECT_DIR"* ]]; then
    WALLPAPER=$(find "$CORRECT_DIR" -maxdepth 1 -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" \) | shuf -n 1) || true
    # Tell noctalia to use this wallpaper
    if [ -n "$WALLPAPER" ] && [ -f "$WALLPAPER" ]; then
        noctalia-shell ipc call wallpaper set "$WALLPAPER" "HDMI-A-4" 2>/dev/null || true
    fi
fi

# Sync noctalia's own dark mode (bar, launcher, notifications, etc.)
if [ "$MODE" = "dark" ]; then
    noctalia-shell ipc call darkMode setDark 2>/dev/null || true
else
    noctalia-shell ipc call darkMode setLight 2>/dev/null || true
fi

# Run matugen for hyprland / wofi / dunst colors
if [ -n "$WALLPAPER" ] && [ -f "$WALLPAPER" ]; then
    matugen image "$WALLPAPER" -m "$MODE" --source-color-index 0 || true
fi

# GTK theme settings
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
    rm -f "$HOME/.config/$gtk_dir/settings.ini"
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

# Alacritty theme
mkdir -p ~/.config/alacritty
rm -f "$HOME/.config/alacritty/theme-colors.toml"

if [ "$MODE" = "dark" ]; then
    cat > "$HOME/.config/alacritty/theme-colors.toml" <<'EOF'
[colors.primary]
background = "#282828"
foreground = "#ebdbb2"

[colors.normal]
black   = "#282828"
red     = "#cc241d"
green   = "#98971a"
yellow  = "#d79921"
blue    = "#458588"
magenta = "#b16286"
cyan    = "#689d6a"
white   = "#a89984"

[colors.bright]
black   = "#928374"
red     = "#fb4934"
green   = "#b8bb26"
yellow  = "#fabd2f"
blue    = "#83a598"
magenta = "#d3869b"
cyan    = "#8ec07c"
white   = "#ebdbb2"
EOF
else
    cat > "$HOME/.config/alacritty/theme-colors.toml" <<'EOF'
[colors.primary]
background = "#fbf1c7"
foreground = "#3c3836"

[colors.normal]
black   = "#fbf1c7"
red     = "#cc241d"
green   = "#98971a"
yellow  = "#d79921"
blue    = "#458588"
magenta = "#b16286"
cyan    = "#689d6a"
white   = "#7c6f64"

[colors.bright]
black   = "#928374"
red     = "#9d0006"
green   = "#79740e"
yellow  = "#b57614"
blue    = "#076678"
magenta = "#8f3f71"
cyan    = "#427b58"
white   = "#3c3836"
EOF
fi
