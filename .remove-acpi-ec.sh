#!/bin/bash
set -e

systemctl enable predator-sense.service || false
systemctl daemon-reload

echo "=== Removing acpi_ec module and cleaning up ==="

# Unload the module if loaded
echo "[1/4] Unloading acpi_ec module..."
if lsmod | grep -q "^acpi_ec"; then
    sudo rmmod acpi_ec
    echo "Module acpi_ec unloaded."
else
    echo "Module acpi_ec is not loaded."
fi

# Remove /dev/ec if it still exists (udev may recreate it)
echo "[2/4] Checking /dev/ec..."
if [ -e /dev/ec ]; then
    echo "Note: /dev/ec still exists. It will disappear after reboot or udev reload."
fi

# Remove the cloned folder
echo "[3/4] Removing acpi_ec directory..."
if [ -d "acpi_ec" ]; then
    rm -rf acpi_ec
    echo "Directory removed."
else
    echo "Directory 'acpi_ec' not found."
fi

echo "[4/4] Cleanup complete."

echo
echo "=== acpi_ec module removed ==="
