#!/usr/bin/env bash

set -euo pipefail

count_waiting="$(dunstctl count waiting)"
count_displayed="$(dunstctl count displayed)"
enabled="$(cat <<'EOF'
{ "text": "󰂜", "tooltip": "notifications <span color='#a6da95'>on</span>", "class": "on" }
EOF
)"
disabled="$(cat <<'EOF'
{ "text": "󰪑", "tooltip": "notifications <span color='#ee99a0'>off</span>", "class": "off" }
EOF
)"

if [ "$count_displayed" -ne 0 ]; then
  enabled="{ \"text\": \"󰂚${count_displayed}\", \"tooltip\": \"${count_displayed} notifications\", \"class\": \"on\" }"
fi

if [ "$count_waiting" -ne 0 ]; then
  disabled="{ \"text\": \"󰂛${count_waiting}\", \"tooltip\": \"(silent) ${count_waiting} notifications\", \"class\": \"off\" }"
fi

if dunstctl is-paused | grep -q false; then
  printf '%s\n' "$enabled"
else
  printf '%s\n' "$disabled"
fi
