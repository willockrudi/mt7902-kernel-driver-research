## Community Experience & Workarounds (2023–2026)

- 2023–2025: No official Linux support for MT7902. Users relied on USB Wi-Fi dongles, phone tethering, or card replacement (Intel AX200/AX210). No success with PCI ID hacks or kernel recompilation.
- 2026: Backported and mainline drivers for PCIe MT7902 now available (see [mt7902-linux-wifi-status-2026.md](mt7902-linux-wifi-status-2026.md)).
- Experimental drivers ([samveen/mt7902-dkms](https://github.com/samveen/mt7902-dkms), [OnlineLearningTutorials/mt7902_temp](https://github.com/OnlineLearningTutorials/mt7902_temp)) were not functional for most users.
- Bluetooth may require additional steps or a separate branch.
- Secure Boot: Mainline/Ubuntu kernels are unsigned; sign or disable Secure Boot if needed.
# MT7902 Linux Enablement - Project Status Log

**Last Updated:** 2026-03-20  
**Overall Status:** 🟢 ON TRACK – MT7902 WiFi/Bluetooth now supported (2026 breakthrough)  
**Next Phase:** Phase 5 (Firmware Loader Implementation, now superseded by backported driver)

---

## Phase Completion Summary

### ✅ Phase 0: Baseline Capture (COMPLETE)
- **Completion:** 2026-03-20
- **Deliverables:**
  - System environment captured (uname, lspci, dmesg)
  - Hardware fully characterized: ASUS Vivobook S Flip TN3604YA, Ryzen 7 7730U
  - MT7902 device ID confirmed: 14c3:7902 @ PCI 01:00.0
  - Kernel version: 6.17.0-19-generic (Linux Mint)
  - Reproducibility checklist created

### ✅ Phase 1: Upstream Reconnaissance (COMPLETE)  
- **Completion:** 2026-03-20
- **Key Finding:** MT7902 ABSENT from kernel 6.17.0-19-generic (at the time)
  - Searched: /usr/src/linux-headers-*/ → 0 hits for "7902"
  - Searched: mt76 driver landscape → device not in mt7603→mt7925 lineup
  - Conclusion: Device was genuinely new to Linux (not misnamed/aliased)
- **Gate A Decision:** NO upstream support → Proceed with custom driver/firmware (later superseded by 2026 backport)
### ✅ Phase 5: Breakthrough (2026)
- **Completion:** 2026-03-20
- **Key Finding:** Backported and mainline drivers for MT7902 WiFi/Bluetooth now available!
  - See [mt7902-linux-wifi-status-2026.md](mt7902-linux-wifi-status-2026.md) for enablement instructions
  - Ubuntu 24.04, Fedora, and other modern distros now supported
  - PCIe modules confirmed working; SDIO pending
  - Project focus shifted from custom loader to documentation and enablement

### ✅ Phase 2: Lab Driver Ready (COMPLETE)
- **Completion:** 2026-03-20
- **Deliverable:** mt7902lab.ko compiled and ready
  - Source: 200 lines (safe PCI probe, read-only)
  - Binary: /home/rudi/mt7902/src/mt7902lab/mt7902lab.ko (369 KB)
  - Features: Device enable, BAR mapping, MMIO read (safe operations only)
  - Status: Ready for first probe test (queued, not executed yet)

### ✅ Phase 3: Driver Research (COMPLETE)
- **Completion:** 2026-03-20  
- **Attempts:**
  - ❌ Windows ASUS driver: Wrong hardware (Realtek, not MediaTek)
  - ✅ GitHub search: Found gen4-mt7902 working Linux driver
- **Result:** Transitioned to superior open-source reference
  - Reason: Source code + firmware blobs enable direct understanding
  - Repository: github.com/hmtheboy154/gen4-mt7902
  - Status: 28MB project, buildable, 2.4GHz WiFi confirmed working

### ✅ Phase 4: Driver Architecture Analysis (COMPLETE)
- **Completion:** 2026-03-20
- **Deliverables:**
  - Firmware extraction: 2 binaries secured
    - WIFI_RAM_CODE_MT7902_1.bin (713 KB) - main microcode
    - WIFI_MT7902_patch_mcu_1_1_hdr.bin (119 KB) - MCU patch
  - Located in: `/home/rudi/mt7902/firmware/`
  - Register map documented
  - Firmware loading sequence reverse-engineered
  - Comparison vs mt7902lab.c completed
  - Document: `/home/rudi/mt7902/docs/phase-3-4-findings.md`

### ✅ Gate B: Firmware Loadability Assessment (PASSED)
- **Decision Date:** 2026-03-20
- **Question:** Can firmware be loaded from Linux?
- **Answer:** YES ✅
- **Evidence:**
  - gen4-mt7902 successfully loads firmware (proven)
  - MCU boots and responds to control registers
  - WiFi connections achieved (2.4GHz working)
  - DMA firmware transfer mechanism documented
- **Verdict:** Proceed to Phase 5 ✅

---

## Phase Roadmap (Remaining)

### 🔵 Phase 5: Firmware Loader Implementation (NEXT)
**Planned Completion:** 2026-03-25  
**Key Tasks:**
1. Extract fw_dl.c functions from gen4-mt7902
2. Port to Linux kernel module (using request_firmware())
3. Integrate with mt7902lab.c PCI probe
4. Test on hardware (capture dmesg, register state)
5. Debug any kernel panics (ASUS HW risk noted)

**Success Criteria:**
- Module loads without error
- Firmware binaries located and loaded
- MCU bootloader confirms ready status
- No kernel panic on this specific Vivobook
- Device enumerable via lspci

**Risk:** Kernel panic reports on ASUS hardware with gen4-mt7902 (mitigated by testing)

### 🔵 Phase 6: Command Protocol Analysis (QUEUED)
**Planned Completion:** TBD (after Phase 5 success)  
- Extract cmd_tx/cmd_rx functions from gen4-mt7902
- Document MT7902 command protocol structure  
- Map WiFi state machine (scan, connect, authenticate)
- Create command parser documentation

### 🔵 Phase 7: Driver Integration (QUEUED)
**Planned Completion:** TBD  
- Integrate firmware loader with full driver code
- Enable nl80211/cfg80211 interface
- Test end-to-end WiFi connectivity
- Performance measurements

### 🔵 Phase 8: Custom Firmware (CONDITIONAL)
**Trigger:** Only if Phase 7 performance unacceptable  
- Extract firmware format from WIFI_RAM_CODE_MT7902_1.bin
- Analyze with binwalk/Ghidra
- Document firmware sections & initialization data
- Modify for performance optimization (if feasible)

---

## Decision Gates & Verdicts

| Gate | Question | Answer | Date | Verdict |
|------|----------|--------|------|---------|
| **A** | Upstream support exists? | NO | 2026-03-20 | ✅ Proceed Phase 2 |
| **B** | Firmware loadable? | YES | 2026-03-20 | ✅ Proceed Phase 5 |
| **C** | Performance acceptable? | TBD | Pending | Pending |
| **D** | Custom firmware needed? | TBD | Pending | Pending |

---

## Risk Register

| Risk | Status | Likelihood | Impact | Mitigation |
|------|--------|-----------|--------|-----------|
| Kernel panic on ASUS HW | ACTIVE | MEDIUM | HIGH | Test Phase 5 on actual hardware; prepare AX210 replacement |
| gen4-mt7902 5GHz broken | KNOWN | MEDIUM | MEDIUM | Known gen4-mt7902 limitation; likely fixable in Phase 7 |
| Suspend/resume issues | KNOWN | LOW | LOW | User can disable power management |
| Firmware version mismatch | LOW | LOW | MEDIUM | Pin specific firmware blobs in loader |
| No official mt76 backport (6.17) | KNOWN | HIGH | LOW | gen4-mt7902 provides working reference |

---

## Hardware Configuration (Reference)

**System:**
- Model: ASUS Vivobook S Flip TN3604YA
- CPU: AMD Ryzen 7 7730U (16 cores)
- RAM: 15.6 GB available
- Wireless: MediaTek MT7902 (PCIe)
  - PCI ID: 14c3:7902
  - Location: Bus 01, Slot 00.0
  - BARs:
    - BAR0: 0xe0300000-0xe03fffff (1MB, 64-bit pref)
    - BAR2: 0xfcf00000-0xfcf07fff (32KB, 64-bit)

**OS:**
- Distribution: Linux Mint (Ubuntu-based)
- Kernel: 6.17.0-19-generic
- Build Tools: build-essential, linux-headers, gcc

---

## Key Artifacts

### Documentation
- `docs/MT7902-Linux-Enablement-Master-Plan.md` — Full 8-phase roadmap
- `docs/phase-1-findings.md` — Upstream reconnaissance results
- `docs/phase-2-execution-guide.md` — Lab driver testing procedures
- `docs/phase-3-4-findings.md` — Driver analysis & firmware details
- `logs/README.md` — Baseline system environment

### Code & Firmware
- `src/mt7902lab/mt7902lab.ko` — Compiled PCI probe module
- `firmware/WIFI_RAM_CODE_MT7902_1.bin` — Main microcode (713 KB)
- `firmware/WIFI_MT7902_patch_mcu_1_1_hdr.bin` — MCU patch (119 KB)

### Build Tools
- `scripts/collect-baseline.sh` — Log collection scripting
- Helper scripts: `run.sh`, `stop.sh` (in mt7902lab/)

---

## Next Immediate Actions

1. **[HIGH] Phase 5 Kickoff:** Extract fw_dl.c from gen4-mt7902/common/
2. **[HIGH] Port to Loader:** Create mt7902_fw_loader.ko skeleton
3. **[MEDIUM] Test Design:** Plan hardware test sequence (capture dmesg, registers)
4. **[MEDIUM] Risk Prep:** Review ASUS kernel panic reports; prepare debug plan
5. **[LOW] Documentation:** Keep this status log updated per phase

---

**Prepared by:** MT7902 Linux Enablement Project  
**Status Last Verified:** 2026-03-20 14:40 UTC  
**Next Review:** After Phase 5 hotspot test (scheduled 2026-03-25)

