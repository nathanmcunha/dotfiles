#!/usr/bin/env bash

set -euo pipefail

backup_file="$HOME/.cache/airplane_backup"

if rfkill list wifi | grep -qi 'Soft blocked: yes'; then
  rfkill unblock wifi
  [ -e "$backup_file" ] && rm -f "$backup_file"
else
  rfkill block wifi
fi
