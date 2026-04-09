#!/usr/bin/env bash

set -euo pipefail

backup_file="$HOME/.cache/airplane_backup"

if [ -e "$backup_file" ]; then
  wifi_status="$(grep -o 'wifi:\(on\|off\)$' "$backup_file" | cut -d: -f2)"
  bluetooth_status="$(grep -o 'bluetooth:\(on\|off\)$' "$backup_file" | cut -d: -f2)"

  if [ "$wifi_status" = "on" ]; then
    rfkill unblock wifi
  fi

  if [ "$bluetooth_status" = "on" ]; then
    rfkill unblock bluetooth
  fi

  rm -f "$backup_file"
else
  mkdir -p "$HOME/.cache"
  if rfkill list wifi | grep -q 'Soft blocked: no'; then
    wifi_state="on"
  else
    wifi_state="off"
  fi

  if rfkill list bluetooth | grep -q 'Soft blocked: no'; then
    bluetooth_state="on"
  else
    bluetooth_state="off"
  fi

  {
    printf 'wifi:%s\n' "$wifi_state"
    printf 'bluetooth:%s\n' "$bluetooth_state"
  } >"$backup_file"

  rfkill block wifi
  rfkill block bluetooth
fi
