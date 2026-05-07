#!/bin/bash
set -e

echo "=== Installing acpi_ec module ==="

# Clone the repository if missing
if [ ! -d "acpi_ec" ]; then
    echo "[1/5] Cloning repository..."
    git clone https://github.com/musikid/acpi_ec/
else
    echo "[1/5] Directory 'acpi_ec' already exists, skipping clone."
fi

# Enter the directory
cd acpi_ec

# Run installer
echo "[2/5] Running install.sh..."
sudo ./install.sh

# Load the kernel module
echo "[3/5] Loading acpi_ec module..."
sudo modprobe acpi_ec

# Check if /dev/ec exists
echo "[4/5] Checking for /dev/ec..."
if [ -e /dev/ec ]; then
    echo "OK: /dev/ec exists."
else
    echo "ERROR: /dev/ec does not exist."
    exit 1
fi

# Read EC to confirm access
echo "[5/5] Reading /dev/ec (first 64 bytes)..."
sudo cat /dev/ec | head -c 64 | hexdump -C

echo
echo "=== acpi_ec module installed and working ==="
