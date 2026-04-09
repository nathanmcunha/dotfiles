#!/usr/bin/env bash

set -euo pipefail

target_process="hyprsunset"
temp_file="$HOME/.cache/hyprsunset_temp"

if pgrep "$target_process" >/dev/null; then
  pkill -INT "$target_process"
  exit 0
fi

temp="4000"
if [ -f "$temp_file" ]; then
  temp="$(cat "$temp_file")"
else
  mkdir -p "$HOME/.cache"
  printf '%s\n' "$temp" >"$temp_file"
fi

nohup "$target_process" -t "$temp" >/dev/null 2>&1 &
