#!/bin/bash
set -e

# Detect the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== Linux-PredatorSense — Building .deb package ==="
echo "Script directory: $SCRIPT_DIR"
echo

# Remove old .deb files
echo "[1/3] Removing old .deb packages..."
rm -f "$SCRIPT_DIR"/*.deb

echo "[2/3] Building main package..."

sudo fpm -s dir -t deb \
  -n linux-predatorsense \
  -v 1.1.0 \
  --vendor "AstromanGaming" \
  --maintainer "Sam Bélanger <contact@astromangaming.ca>" \
  --license "GPL-3.0" \
  --url "https://github.com/AstromanGaming/Linux-PredatorSense/" \
  --description "A derived project clone of Acer's Predator Sense™ application for Linux" \
  --architecture amd64 \
  --before-remove "$SCRIPT_DIR/.remove-acpi-ec.sh" \
  --after-install "$SCRIPT_DIR/.install-acpi-ec.sh" \
  --depends python3-pyqt5 \
  --depends python3-pyqt5.qtchart \
  --depends msr-tools \
  --depends python3-evdev \
  "$SCRIPT_DIR/.remove-acpi-ec.sh=/opt/Linux-PredatorSense/.remove-acpi-ec.sh" \
  "$SCRIPT_DIR/.install-acpi-ec.sh=/opt/Linux-PredatorSense/.install-acpi-ec.sh" \
  "$SCRIPT_DIR/app_icon.ico=/opt/Linux-PredatorSense/app_icon.ico" \
  "$SCRIPT_DIR/monitor_evdev.py=/opt/Linux-PredatorSense/monitor_evdev.py" \
  "$SCRIPT_DIR/prepare_xenv.sh=/opt/Linux-PredatorSense/prepare_xenv.sh" \
  "$SCRIPT_DIR/wrapper.sh=/opt/Linux-PredatorSense/wrapper.sh" \
  "$SCRIPT_DIR/predator-sense.service=/etc/systemd/system/predator-sense.service" \
  "$SCRIPT_DIR/predator-sense-gui.service=/usr/lib/systemd/user/predator-sense-gui.service" \
  "$SCRIPT_DIR/ecwrite.py=/opt/Linux-PredatorSense/ecwrite.py" \
  "$SCRIPT_DIR/frontend.py=/opt/Linux-PredatorSense/frontend.py" \
  "$SCRIPT_DIR/LICENSE.md=/opt/Linux-PredatorSense/LICENSE.md" \
  "$SCRIPT_DIR/main.py=/opt/Linux-PredatorSense/main.py" \
  "$SCRIPT_DIR/main.spec=/opt/Linux-PredatorSense/main.spec" \
  "$SCRIPT_DIR/PredatorLogo.png=/opt/Linux-PredatorSense/PredatorLogo.png" \
  "$SCRIPT_DIR/predator-sense.desktop=/usr/share/applications/predator-sense.desktop" \
  "$SCRIPT_DIR/fonts/=/opt/Linux-PredatorSense/fonts/" 

echo
echo "=== Build completed successfully ==="
echo "Generated packages are located in: $SCRIPT_DIR"