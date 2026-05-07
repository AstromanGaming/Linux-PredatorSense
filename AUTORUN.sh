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
  -v 1.0.0 \
  --before-remove "$SCRIPT_DIR/.remove-acpi-ec.sh" \
  --after-install "$SCRIPT_DIR/.install-acpi-ec.sh" \
  --vendor "AstromanGaming" \
  --maintainer "Sam Bélanger <contact@astromangaming.ca>" \
  --license "GPL-3.0" \
  --url "https://github.com/AstromanGaming/Linux-PredatorSense/" \
  --description "A derived project clone of Acer's Predator Sense™ application for Linux" \
  --architecture amd64 \
  --depends python3-pyqt5 \
  --depends python3-pyqt5.qtchart \
  --depends msr-tools \
  "$SCRIPT_DIR/.remove-acpi-ec.sh=/opt/Linux-PredatorSense/" \
  "$SCRIPT_DIR/.install-acpi-ec.sh=/opt/Linux-PredatorSense/" \
  "$SCRIPT_DIR/app_icon.ico=/opt/Linux-PredatorSense/" \
  "$SCRIPT_DIR/ecwrite.py=/opt/Linux-PredatorSense/" \
  "$SCRIPT_DIR/frontend.py=/opt/Linux-PredatorSense/" \
  "$SCRIPT_DIR/LICENSE.md=/opt/Linux-PredatorSense/" \
  "$SCRIPT_DIR/main.py=/opt/Linux-PredatorSense/" \
  "$SCRIPT_DIR/main.spec=/opt/Linux-PredatorSense/" \
  "$SCRIPT_DIR/PredatorLogo.png=/opt/Linux-PredatorSense/" \
  "$SCRIPT_DIR/predator-sense.desktop=/usr/share/applications/" \
  "$SCRIPT_DIR/fonts/=/opt/Linux-PredatorSense/fonts/" \

echo
echo "=== Build completed successfully ==="
echo "Generated packages are located in: $SCRIPT_DIR"
