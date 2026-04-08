#!/usr/bin/env bash

set -euo pipefail

backup_file="$HOME/.cache/airplane_backup"

if [ -e "$backup_file" ]; then
  printf '%s\n' '{ "text":"󰀝", "tooltip": "airplane-mode <span color='\''#a6da95'\''>on</span>", "class": "on" }'
else
  printf '%s\n' '{ "text":"󰀞", "tooltip": "airplane-mode <span color='\''#ee99a0'\''>off</span>", "class": "off" }'
fi
