#!/usr/bin/env bash

set -euo pipefail

if pgrep geoclue >/dev/null; then
  printf '%s\n' '{"text":"󰆤", "tooltip":"Geopositioning", "alt":"Geo"}'
fi
