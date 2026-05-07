#!/bin/bash

echo "=== Installing acpi_ec module ==="

# Clone the repository if missing
if [ ! -d "acpi_ec" ]; then
    echo "[1/5] Cloning repository..."
    git clone https://github.com/musikid/acpi_ec/ || true
else
    echo "[1/5] Directory 'acpi_ec' already exists, skipping clone."
fi

# Enter the directory
cd acpi_ec || exit 0

# Run installer (never fail)
echo "[2/5] Running install.sh..."
sudo ./install.sh || true

# Load the kernel module (never fail)
echo "[3/5] Loading acpi_ec module..."
sudo modprobe acpi_ec || true

# Check if /dev/ec exists
echo "[4/5] Checking for /dev/ec..."
if [ -e /dev/ec ]; then
    echo "OK: /dev/ec exists."
else
    echo "WARNING: /dev/ec does not exist. Continuing anyway."
fi

# Read EC to confirm access (never fail)
echo "[5/5] Reading /dev/ec (first 64 bytes)..."
sudo cat /dev/ec 2>/dev/null | head -c 64 | hexdump -C || true

echo
echo "=== acpi_ec module installation script completed ==="

exit 0
