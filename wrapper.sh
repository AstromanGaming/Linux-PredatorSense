#!/usr/bin/env bash
set -euo pipefail

SOFT_DIR="/opt/Linux-PredatorSense/"
ENVFILE="/tmp/predator_env.sh"

CMD="cd \"$SOFT_DIR\" && python3 main.py"

if [ "${1:-}" = "--root" ]; then
  if [ -r "$ENVFILE" ]; then
    . "$ENVFILE"
  fi
  exec /bin/bash -lc "$CMD"
else
  pkexec env DISPLAY="${DISPLAY:-}" XAUTHORITY="${XAUTHORITY:-}" sh -c "$CMD"
fi
