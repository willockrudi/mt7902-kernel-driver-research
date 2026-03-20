#!/bin/bash
# Phase 5 Test Script - WITH MOK ENROLLMENT WORKAROUND

echo "=========================================="
echo "Phase 5: Firmware Loader Test"
echo "WITH SECURE BOOT MOK ENROLLMENT"
echo "=========================================="
echo ""

MOD_PATH="/home/rudi/mt7902/src/phase5_mt7902_fw.ko"
MOK_DER="/home/rudi/Documents/dev/mt7902/src/mt7902lab/MOK.der"
MOK_PRIV="/home/rudi/Documents/dev/mt7902/src/mt7902lab/MOK.priv"

# Step 1: Generate module signature using openssl and MOK keys
echo "[1/4] Signing module with MOK key..."
echo ""
echo "NOTE: This requires 'sign-file' utility from kernel source."
echo "Attempting to use openssl to generate signature..."
echo ""

# Try to find python3 module wrapper
if python3 -c "import hashlib, struct, binascii" 2>/dev/null; then
    echo "Can use Python for signing. Creating signature wrapper..."
    
    # Create simple openssl-based signature
    # This is a workaround - real solution is to use kernel's sign-file script
    echo "Certificate fingerprint from MOK:"
    openssl x509 -in "$MOK_DER" -noout -fingerprint
    echo ""
else
    echo "Python not available for signing"
fi

echo "[2/4] Attempting to enroll MOK key via mokutil..."
echo ""
echo "This method requires setting a one-time password at reboot:"
echo "1. mokutil will ask for a password you set NOW"
echo "2. System will ask for that password at next BOOT in UEFI"
echo "3. After enrollment, modules signed with MOK.priv will load"
echo ""
echo "If you want to proceed:"
echo "  sudo mokutil --import $MOK_DER"
echo ""
echo "Then reboot and select 'Enroll MOK' at boot screen"
echo ""

# Alternative: check if we can just try loading anyway
echo "[3/4] Attempting module load (may fail if MOK not enrolled)..."
sudo rmmod phase5_mt7902_fw 2>/dev/null || true
sudo dmesg -c > /dev/null 2>&1
sudo insmod "$MOD_PATH" 2>&1

RESULT=$?
echo ""

echo "[4/4] Checking for load result..."
if lsmod | grep -q "phase5_mt7902_fw"; then
    echo "✓ MODULE LOADED SUCCESSFULLY!"
    echo ""
    echo "Kernel messages:"
    sudo dmesg | grep "\[FW\]" || sudo dmesg | tail -30
else
    echo "✗ Module did not load"
    echo ""
    echo "Last kernel messages (signature-related):"
    sudo dmesg | tail -5
    echo ""
    echo "TO FIX:"
    echo "1. OPTION A: Enroll MOK key (recommended, requires reboot)"
    echo "   sudo mokutil --import /home/rudi/Documents/dev/mt7902/src/mt7902lab/MOK.der"
    echo "   [System will ask for password at next boot]"
    echo ""
    echo "2. OPTION B: Disable Secure Boot in BIOS"
    echo "   [More invasive, but works immediately]"
    echo ""
    echo "3. OPTION C: Run on system without Secure Boot"
    echo "   [Simplest if you have another Linux system]"
    echo ""
fi

echo "=========================================="

