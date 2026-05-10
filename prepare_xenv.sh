#!/bin/sh
OUT="/tmp/predator_env.sh"
rm -f "$OUT"

# Find an active graphical session (prefer seat0)
SESSION=$(loginctl list-sessions --no-legend | awk '/seat0/ {print $1; exit}')
if [ -z "$SESSION" ]; then
  SESSION=$(loginctl list-sessions --no-legend | awk '{print $1; exit}')
fi

USER_NAME=""
USER_ID=""
LEADER=""
if [ -n "$SESSION" ]; then
  USER_NAME=$(loginctl show-session "$SESSION" -p Name --value 2>/dev/null)
  USER_ID=$(loginctl show-session "$SESSION" -p UID --value 2>/dev/null)
  LEADER=$(loginctl show-session "$SESSION" -p Leader --value 2>/dev/null)
fi

# Fallback to first non-root user with /run/user
if [ -z "$USER_NAME" ] || [ -z "$USER_ID" ]; then
  for uid in $(ls /run/user 2>/dev/null); do
    [ "$uid" -ne 0 ] 2>/dev/null && { USER_ID="$uid"; break; }
  done
  USER_NAME=$(getent passwd "$USER_ID" | cut -d: -f1 || true)
fi

RUNTIME="/run/user/${USER_ID:-1000}"

# Determine leader PID environ file if available
ENVFILE=""
if [ -n "$LEADER" ] && [ -r "/proc/$LEADER/environ" ]; then
  ENVFILE="/proc/$LEADER/environ"
fi

DISPLAY_VAL=""
WAYLAND_VAL=""
DBUS_VAL=""
XAUTH=""

if [ -n "$ENVFILE" ]; then
  DISPLAY_VAL=$(tr '\0' '\n' < "$ENVFILE" | awk -F= '/^DISPLAY=/ {print $2; exit}')
  WAYLAND_VAL=$(tr '\0' '\n' < "$ENVFILE" | awk -F= '/^WAYLAND_DISPLAY=/ {print $2; exit}')
  DBUS_VAL=$(tr '\0' '\n' < "$ENVFILE" | awk -F= '/^DBUS_SESSION_BUS_ADDRESS=/ {print $2; exit}')
  XAUTH=$(tr '\0' '\n' < "$ENVFILE" | awk -F= '/^XAUTHORITY=/ {print $2; exit}')
fi

# Fallbacks: prefer /run/user/UID/.Xauthority, then /home/USER/.Xauthority
if [ -z "$XAUTH" ]; then
  if [ -r "/run/user/${USER_ID}/.Xauthority" ]; then
    XAUTH="/run/user/${USER_ID}/.Xauthority"
  elif [ -r "/home/${USER_NAME}/.Xauthority" ]; then
    XAUTH="/home/${USER_NAME}/.Xauthority"
  else
    XAUTH=""
  fi
fi

[ -z "$DISPLAY_VAL" ] && DISPLAY_VAL=":0"
[ -z "$DBUS_VAL" ] && DBUS_VAL="unix:path=${RUNTIME}/bus"
[ -z "$WAYLAND_VAL" ] && WAYLAND_VAL=""

if [ -n "$WAYLAND_VAL" ]; then
  QT_PLATFORM="wayland"
else
  QT_PLATFORM="xcb"
fi

# Write KEY=VALUE lines (no export) for systemd EnvironmentFile compatibility
{
  echo "USER_NAME=${USER_NAME}"
  echo "USER_ID=${USER_ID}"
  echo "DISPLAY=${DISPLAY_VAL}"
  echo "WAYLAND_DISPLAY=${WAYLAND_VAL}"
  echo "QT_QPA_PLATFORM=${QT_PLATFORM}"
  echo "XDG_RUNTIME_DIR=${RUNTIME}"
  echo "DBUS_SESSION_BUS_ADDRESS=${DBUS_VAL}"
  echo "XAUTHORITY=${XAUTH}"
} > "$OUT"

chmod 600 "$OUT"
exit 0
