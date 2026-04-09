#!/usr/bin/env bash

set -euo pipefail

process_pids="$(fuser /dev/video0 2>/dev/null | awk '{print $2}' | sort -u)"

if [ -n "$process_pids" ]; then
  processes=""
  for process_pid in $process_pids; do
    process_name="$(ps -q "$process_pid" -o comm=)"
    processes="${processes}\n<span color='#eed49f'>${process_name}(${process_pid})</span>"
  done
  printf '%s\n' "{\"text\":\"󰖠\", \"tooltip\":\"webcam is used by: ${processes}\", \"alt\":\"Webcam\"}"
fi
