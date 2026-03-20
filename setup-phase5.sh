#!/bin/bash
# Phase 5: Install firmware and build module

set -e

FW_DIR="/lib/firmware/mediatek"
FW_SOURCE="/home/rudi/mt7902/firmware"

echo "=========================================="
echo "Phase 5: Firmware Loader Setup"
echo "=========================================="

# Install firmware
echo "[1/3] Installing firmware binaries..."
if [ ! -d "$FW_DIR" ]; then
    echo "Creating $FW_DIR..."
    sudo mkdir -p "$FW_DIR"
fi

echo "Copying firmware from $FW_SOURCE to $FW_DIR..."
sudo cp -v "$FW_SOURCE/WIFI_RAM_CODE_MT7902_1.bin" "$FW_DIR/" || echo "Warning: MCU code copy may have failed"
sudo cp -v "$FW_SOURCE/WIFI_MT7902_patch_mcu_1_1_hdr.bin" "$FW_DIR/" || echo "Warning: MCU patch copy may have failed"

# Verify installation
echo ""
echo "Verifying firmware installation..."
if [ -f "$FW_DIR/WIFI_RAM_CODE_MT7902_1.bin" ]; then
    echo "✓ MCU code found: $(ls -lh $FW_DIR/WIFI_RAM_CODE_MT7902_1.bin | awk '{print $5}')"
else
    echo "✗ MCU code NOT found"
fi

if [ -f "$FW_DIR/WIFI_MT7902_patch_mcu_1_1_hdr.bin" ]; then
    echo "✓ MCU patch found: $(ls -lh $FW_DIR/WIFI_MT7902_patch_mcu_1_1_hdr.bin | awk '{print $5}')"
else
    echo "✗ MCU patch NOT found"
fi

# Build module
echo ""
echo "[2/3] Building Phase 5 firmware loader module..."
cd /home/rudi/mt7902/src
make clean 2>/dev/null || true
make || {
    echo "✗ Module build failed!"
    exit 1
}

if [ -f "phase5_mt7902_fw.ko" ]; then
    echo "✓ Module built successfully: $(ls -lh phase5_mt7902_fw.ko | awk '{print $5}')"
else
    echo "✗ Module build FAILED - no .ko file"
    exit 1
fi

# Summary
echo ""
echo "[3/3] Setup Complete!"
echo "=========================================="
echo "Next Steps:"
echo ""
echo "1. Load the module:"
echo "   cd /home/rudi/mt7902/src"
echo "   sudo insmod phase5_mt7902_fw.ko"
echo ""
echo "2. Check logs:"
echo "   dmesg | grep FW"
echo ""
echo "3. Monitor in real-time:"
echo "   sudo journalctl -u kernel -f"
echo ""
echo "4. On success, check MCU register state:"
echo "   cat /sys/kernel/debug/pci/<device-id>/register_state"
echo ""
echo "=========================================="

