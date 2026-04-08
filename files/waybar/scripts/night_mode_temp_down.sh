#!/usr/bin/env bash

set -euo pipefail

target_process="hyprsunset"
temp_file="$HOME/.cache/hyprsunset_temp"
decrement=100

if ! pgrep "$target_process" >/dev/null; then
  exit 0
fi

current_temp="4000"
if [ -f "$temp_file" ]; then
  current_temp="$(cat "$temp_file")"
fi

new_temp=$((current_temp - decrement))
if [ "$new_temp" -lt 2000 ]; then
  new_temp=2000
fi

mkdir -p "$HOME/.cache"
printf '%s\n' "$new_temp" >"$temp_file"

pkill -INT "$target_process"
sleep 0.5
nohup "$target_process" -t "$new_temp" >/dev/null 2>&1 &
