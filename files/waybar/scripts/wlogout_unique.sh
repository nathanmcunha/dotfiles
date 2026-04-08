#!/usr/bin/env bash

set -euo pipefail

if ! pgrep -x wlogout >/dev/null; then
  wlogout
fi
