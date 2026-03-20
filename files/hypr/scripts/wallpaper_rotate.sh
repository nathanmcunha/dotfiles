#!/bin/bash

# Configuração
MONITOR="HDMI-A-4"
DIR="/home/nathanmcunha/Pictures/Wallpapers"
INTERVALO=6000  # Tempo em segundos (300s = 5 minutos)

while true; do
    # Escolhe uma imagem aleatória .png da pasta
    WALLPAPER=$(find "$DIR" -name "*.png" | shuf -n 1)

    # Manda o Hyprpaper trocar a imagem
    # Retry connection to hyprpaper if needed
    for i in {1..5}; do
        if hyprctl hyprpaper wallpaper "$MONITOR,$WALLPAPER" 2>/dev/null; then
            break
        fi
        sleep 0.5
    done

    matugen image "$WALLPAPER" --prefer darkness

    # Espera o tempo definido
    sleep $INTERVALO
done
