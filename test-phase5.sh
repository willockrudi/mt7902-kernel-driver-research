#!/bin/bash
# Phase 5 Test Script

echo "=========================================="
echo "Phase 5: Firmware Loader Test"
echo "=========================================="

MODULE="/home/rudi/mt7902/src/phase5_mt7902_fw.ko"
FW_DIR="/lib/firmware/mediatek"

if [ ! -f "$MODULE" ]; then
    echo "✗ Module not found: $MODULE"
    exit 1
fi

echo "[1/3] Verifying firmware installation..."
if [ -f "$FW_DIR/WIFI_RAM_CODE_MT7902_1.bin" ] && [ -f "$FW_DIR/WIFI_MT7902_patch_mcu_1_1_hdr.bin" ]; then
    echo "✓ Firmware files present in $FW_DIR"
else
    echo "✗ Firmware files missing!"
    echo "  Expected: $FW_DIR/WIFI_RAM_CODE_MT7902_1.bin"
    echo "  Expected: $FW_DIR/WIFI_MT7902_patch_mcu_1_1_hdr.bin"
fi

echo ""
echo "[2/3] Clearing kernel message buffer..."
sudo dmesg -c > /dev/null 2>&1 || true

echo ""
echo "[3/3] Loading firmware loader module..."
echo "Command: sudo insmod $MODULE"
echo ""
echo "=== MODULE LOAD OUTPUT ===" 
set +e
sudo insmod "$MODULE" 2>&1
LOAD_RESULT=$?
set -e

echo ""
echo "=== KERNEL MESSAGES (with [FW] marker) ===" 
echo ""
sudo dmesg | grep "\[FW\]" || {
    echo "No [FW] messages found. Showing last kernel messages:"
    sudo dmesg | tail -50
}

echo ""
echo "=========================================="
if [ $LOAD_RESULT -eq 0 ]; then
    echo "✓ Module loaded successfully"
else
    echo "✗ Module load returned error: $LOAD_RESULT"
fi
echo "=========================================="

echo ""
echo "To unload module and see removal logs:"
echo "  sudo rmmod phase5_mt7902_fw"
echo "  dmesg | grep FW"
echo ""
echo "To reload and test again:"
echo "  cd /home/rudi/mt7902/src"
echo "  sudo insmod phase5_mt7902_fw.ko"
echo ""

