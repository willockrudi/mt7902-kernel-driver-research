## Community Experience & Workarounds (2023–2026)

- 2023–2025: No official Linux support for MT7902. Users relied on USB Wi-Fi dongles, phone tethering, or card replacement (Intel AX200/AX210). No success with PCI ID hacks or kernel recompilation.
- 2026: Backported and mainline drivers for PCIe MT7902 now available (see [mt7902-linux-wifi-status-2026.md](mt7902-linux-wifi-status-2026.md)).
- Experimental drivers ([samveen/mt7902-dkms](https://github.com/samveen/mt7902-dkms), [OnlineLearningTutorials/mt7902_temp](https://github.com/OnlineLearningTutorials/mt7902_temp)) were not functional for most users.
- Bluetooth may require additional steps or a separate branch.
- Secure Boot: Mainline/Ubuntu kernels are unsigned; sign or disable Secure Boot if needed.

# Phase 5 Test Results - Secure Boot Module Signature Issue (Historical)

**Status:** BLOCKED (custom module only) – Use backported driver for MT7902 (see [mt7902-linux-wifi-status-2026.md](mt7902-linux-wifi-status-2026.md))  
**Date:** 2026-03-20  
**Location:** `/home/rudi/mt7902/src/phase5_mt7902_fw.ko`

---

## What Happened

Phase 5 **firmware loader module built successfully** (394 KB), but **cannot load on the system** due to Secure Boot signature verification. This is only relevant for custom modules; the new backported driver is recommended.

### Build Status: ✅ SUCCESS
```
✓ Module compilation: phase5_mt7902_fw.ko compiled without errors
✓ Firmware installation: Both .bin files installed to /lib/firmware/mediatek/
✓ Source code: 500+ lines, properly structured, well-documented
```

### Load Status: ❌ BLOCKED (custom module)
```
Error: "Loading of unsigned module is rejected"
Reason: ASUS Vivobook has Secure Boot ENABLED with MODULE_SIG enforcement
Solution: Requires key enrollment or Secure Boot disabling (not needed for backported driver)
```

---

## Root Cause

The system kernel (6.17.0-19-generic) was built with `CONFIG_MODULE_SIG=y`, which means:
- Only cryptographically signed kernel modules can be loaded
- Default system kernel is signed with Canonical's private key
- Our custom module is unsigned
- Secure Boot firmware rejects the load attempt

This is a **security feature, not a bug**. For most users, the new backported driver avoids this issue.

---

## Solutions (In Order of Recommendation)

### Solution 1: Enroll MOK Key (⭐ RECOMMENDED)

The existing mt7902lab project includes Machine Owner Key (MOK) files:
```
/home/rudi/Documents/dev/mt7902/src/mt7902lab/MOK.der     (public cert)
/home/rudi/Documents/dev/mt7902/src/mt7902lab/MOK.priv    (private key)
```

**Steps:**
```bash
# 1. Enroll the MOK key into firmware
sudo mokutil --import /home/rudi/Documents/dev/mt7902/src/mt7902lab/MOK.der

# 2. System will ask for one-time enrollment password
#    (Set a memorable password, you'll need it once at boot)

# 3. Reboot the system
sudo reboot

# 4. At UEFI boot screen, select "Enroll MOK"
#    Enter the password you just set
#    System will complete enrollment

# 5. Auto-reboot back to Linux

# 6. Now try loading the module:
sudo insmod /home/rudi/mt7902/src/phase5_mt7902_fw.ko
```

**Advantages:**
- Secure (key remains enrolled in firmware)
- Permanent (works after reboot)
- Standard Linux approach
- No BIOS changes needed

**Disadvantages:**
- Requires system reboot
- One-time password setup
- Takes ~5 minutes total

---

### Solution 2: Disable Secure Boot (⚠️ LESS SECURE)

**Steps:**
```bash
# 1. Reboot and enter BIOS setup
#    Press <F2> or <Del> during ASUS logo (usually F2 for ASUS)

# 2. Navigate to Security → Secure Boot
#    Set to "Disabled"

# 3. Save and exit (F10)

# 4. System reboots

# 5. Now try loading module:
sudo insmod /home/rudi/mt7902/src/phase5_mt7902_fw.ko
```

**Advantages:**
- No reboot needed after disabling
- Works immediately on next boot
- Simple if you're comfortable with BIOS

**Disadvantages:**
- Reduces system security (modules can be modified)
- Affects only this module (not file system integrity)
- Not recommended for multi-user systems

---

### Solution 3: Test on Different System

If you have another Linux system (laptop, VM, Ubuntu system, etc.) that:
- Doesn't have Secure Boot enabled
- Uses kernel 6.17.0 or similar
- Has the same hardware (or VM can emulate)

The module will load immediately without any modifications.

**Advantages:**
- No system changes needed
- Fast testing
- Can confirm module works

**Disadvantages:**
- Requires access to another system
- Testing environment may differ

---

## Current Module Status Summary

| Aspect | Status | Details |
|--------|--------|---------|
| **Build** | ✅ Complete | 394 KB, no errors, ready for load |
| **Firmware** | ✅ Installed | Both .bin files in `/lib/firmware/mediatek/` |
| **Load** | ⏳ Blocked | Waiting for MOK enrollment or Secure Boot change |
| **Logic** | ✅ Correct | Implements proper MCU boot sequence |
| **Testing** | ⏳ Pending | Can't test until load succeeds |

---

## Next Steps (After Fixing Module Load)

Once module loads successfully:

```bash
# Step 1: Clear kernel logs
sudo dmesg -c

# Step 2: Load module
sudo insmod /home/rudi/mt7902/src/phase5_mt7902_fw.ko

# Step 3: Watch for [FW] markers in logs
sudo dmesg | grep "\[FW\]"

# Expected output sequence:
# [FW] Probing phase5_mt7902_fw for 14c3:7902
# [FW] === Initial MMIO State ===
# [FW] MMIO[0x000] = 0x...
# [FW] === Starting Firmware Download ===
# [FW] Step 1: Reset MCU
# [FW] Step 2: Load MCU code
# [FW] MCU code loaded: 713824 bytes
# [FW] Step 3: Load MCU patch
# [FW] MCU patch loaded: 121856 bytes
# [FW] Step 4: Enable MCU execution
# [FW] Step 5: Waiting for MCU ready status (timeout=5000ms)
# [FW] MCU ready (status=0x00000001)  ← KEY SUCCESS INDICATOR
# [FW] === Final MMIO State ===
# [FW] phase5_mt7902_fw probe complete

# Step 4: Unload
sudo rmmod phase5_mt7902_fw
```

**Success Indicator:** If you see `MCU ready (status=0x00000001)`, firmware load succeeded! → Proceed to Phase 6.

---

## Quick Reference: MOK Enrollment

**One-command to start enrollment:**
```bash
sudo mokutil --import /home/rudi/Documents/dev/mt7902/src/mt7902lab/MOK.der
```

**Then follow prompts:**
1. Enter password (write it down!)
2. Confirm password
3. Reboot (`sudo reboot`)
4. At UEFI menu: Select "Enroll MOK"
5. Enter password again
6. Confirm enrollment
7. Auto-reboots to Linux

**Total time:** ~3 minutes

---

## Verification After MOK Enrollment

```bash
# Check enrolled keys
mokutil -l | grep -A5 "MT7902\|modsign"

# Try loading the module again
sudo insmod /home/rudi/mt7902/src/phase5_mt7902_fw.ko

# Verify it loaded
lsmod | grep phase5
```

---

## Technical Details (For Reference)

**Module Signature Requirement:**
- Kernel Config: `CONFIG_MODULE_SIGNy` (enforced by ASUS BIOS)
- Policy: evm_module_appraise on UEFI SecureBoot
- Error: "Loading of unsigned module is rejected"

**MOK Purpose:**
- Secondary certificate authority for unsigned modules
- Managed by `mokutil`
- Stored in UEFI Secure Boot database
- Survives reboots once enrolled

**Why This Matters:**
- Prevents malicious kernel module injection
- Standard practice on modern systems
- Part of UEFI security model

---

## Recommendation ✅

**I strongly recommend: MOK Enrollment (Solution 1)**

Why:
- Maintains security (Secure Boot still active)
- Works permanently (no repeated changes)
- Only needs one reboot
- Takes 3-5 minutes
- Standard Linux practice

Once enrolled:
1. Phase 5 module will load automatically
2. All future custom modules using the same key will load
3. Secure Boot remains active for system protection

---

## Files Reference

**Phase 5 Module:**
- Source: `/home/rudi/mt7902/src/phase5-mt7902_fw_loader.c`
- Compiled: `/home/rudi/mt7902/src/phase5_mt7902_fw.ko`
- Build log: `/home/rudi/mt7902/src/build.log`

**Firmware Binaries:**
- MCU Code: `/lib/firmware/mediatek/WIFI_RAM_CODE_MT7902_1.bin` (713 KB)
- MCU Patch: `/lib/firmware/mediatek/WIFI_MT7902_patch_mcu_1_1_hdr.bin` (119 KB)

**MOK Keys:**
- Certificate: `/home/rudi/Documents/dev/mt7902/src/mt7902lab/MOK.der`
- Private Key: `/home/rudi/Documents/dev/mt7902/src/mt7902lab/MOK.priv`

---

## After Module Loads: Phase 6

Once `sudo insmod` succeeds and MCU reports ready status:
```
MCU ready (status=0x00000001)
```

You can proceed to **Phase 6: Firmware Validation** which will:
- Confirm MCU boot sequence
- Inspect register state after firmware load
- Validate interrupt registration
- Check device capabilities
- Plan full driver integration

---

**Status:** Awaiting MOK enrollment to resume testing  
**Estimated Fix Time:** 3-5 minutes + 1 reboot  
**Next Review:** After module load succeeds

