#!/usr/bin/env bash

set -euo pipefail

if pgrep wl-screenrec >/dev/null; then
  printf '%s\n' '{"text":"", "tooltip":"Recording", "alt":"Recording"}'
fi
