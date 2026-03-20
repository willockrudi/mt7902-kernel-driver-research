## Linux Mint & Ubuntu Community Experience (2023–2026)

- **2023–2025:** No official Linux kernel support for MT7902. The `mt7921e` driver does not work for this device. Most users relied on USB Wi-Fi dongles, phone tethering, or card replacement (Intel AX200/AX210).
- **2026:** Backported and mainline drivers are now available for PCIe MT7902 in kernels 6.6–6.19 and later (see [hmtheboy154/mt7902](https://github.com/hmtheboy154/mt7902)).
- **Experimental drivers:** [samveen/mt7902-dkms](https://github.com/samveen/mt7902-dkms) and [OnlineLearningTutorials/mt7902_temp](https://github.com/OnlineLearningTutorials/mt7902_temp) were not functional for most users.
- **No success with PCI ID hacks:** Adding the MT7902 PCI ID to the `mt7921e` driver or recompiling the kernel did not work.
- **Bluetooth:** May require a separate backport branch or additional steps (see the same repo).
- **Secure Boot:** Mainline/Ubuntu kernels from kernel.ubuntu.com are unsigned. If Secure Boot is enabled, you must sign the kernel or disable Secure Boot.

### How to Enable MT7902 Wi-Fi (2026, PCIe only)
1. Upgrade your kernel to 6.6 or newer (preferably 6.8+).
2. Install the backported driver:
	```sh
	sudo apt install git build-essential dkms
	git clone https://github.com/hmtheboy154/mt7902
	cd mt7902
	make -j$(nproc)
	sudo make install
	sudo make install_fw
	sudo modprobe mt7902e
	```
3. Check Wi-Fi availability: Use your network manager or `iwconfig`.

### If You Cannot Upgrade Kernel
- Use a supported USB Wi-Fi dongle ([morrownr/USB-WiFi](https://github.com/morrownr/USB-WiFi)).
- Use phone tethering for temporary internet.
- Consider replacing the card with a supported Intel model.

### References
- [hmtheboy154/mt7902](https://github.com/hmtheboy154/mt7902) (recommended driver, 2026+)
- [morrownr/USB-WiFi](https://github.com/morrownr/USB-WiFi) (USB dongle compatibility)
- [samveen/mt7902-dkms](https://github.com/samveen/mt7902-dkms) (experimental)
- [OnlineLearningTutorials/mt7902_temp](https://github.com/OnlineLearningTutorials/mt7902_temp) (experimental)
- [Linux Mint Kernel Updates](https://linuxmint-user-guide.readthedocs.io/en/latest/mintupdate.html#kernel-updates)
- [Ubuntu Mainline Kernel Builds](https://wiki.ubuntu.com/Kernel/MainlineBuilds)


# MediaTek MT7902 WiFi & Bluetooth on Linux: Status, History, and Enablement (2026)

## Current Status (2026)
- **WiFi and Bluetooth support for MediaTek MT7902 is now available** via a backported driver (and will be mainline in Linux 7.0+).
- Works on Ubuntu 24.04, Fedora, and other recent distributions with kernel 6.6–6.19 (and later).
- PCIe modules are supported; SDIO modules may require a different approach.
- See [hmtheboy154/mt7902](https://github.com/hmtheboy154/mt7902) for the latest driver and instructions.

---

## Historical Context (2023–2025)
- **No official or community-supported Linux WiFi driver existed for the MT7902 chip** until early 2026.
- Fedora and Ubuntu users repeatedly reported that the card was not supported, and the only workaround was to use a USB WiFi dongle or replace the card with an Intel model.
- The mt76 driver does **not** support MT7902 (only MT76x0e, MT76x2e, MT7603, MT7615, MT7628, MT7688).
- Bluetooth support was patchy, but some community scripts (e.g., [mt7902-bluetooth-arch-fix](https://github.com/ismailtrm/mt7902-bluetooth-arch-fix)) provided partial solutions.
- Many users and forum moderators recommended emailing MediaTek or signing petitions to encourage Linux support.

---

## How to Enable MT7902 WiFi and Bluetooth (2026)
### WiFi
1. **Clone the driver repo:**
	```sh
	git clone https://github.com/hmtheboy154/mt7902
	cd mt7902/
	make -j$(nproc)
	sudo make install
	```
2. **(Optional) Install firmware:**
	```sh
	sudo make install_fw
	```
3. **Load the driver:**
	```sh
	sudo modprobe mt7902e
	```
4. **WiFi should now be available!**

### Bluetooth
1. **Clone the Bluetooth backport branch:**
	```sh
	git clone https://github.com/hmtheboy154/mt7902 -b bluetooth_backport btusb_mt7902
	cd btusb_mt7902/
	make -j$(nproc)
	sudo make install
	sudo make install_fw
	```
2. **Unload conflicting modules and load the new one:**
	```sh
	sudo rmmod btusb
	sudo rmmod btmtk
	sudo modprobe btusb_mt7902
	```
3. **(Optional) Blacklist old modules permanently:**
	- Create `/etc/modprobe.d/blacklist_btusb.conf` with:
	  ```
	  blacklist btusb
	  blacklist btmtk
	  ```

---

## Performance
- WiFi speeds of 400–450 Mbps (with a 600 Mbps link) have been reported.
- Bluetooth file transfers and pairing work after using the correct branch and blacklisting old modules.

---

## References
- [hmtheboy154/mt7902 GitHub repo](https://github.com/hmtheboy154/mt7902)
- [CNX Software: Enabling MediaTek MT7902 WiFi and Bluetooth drivers on Ubuntu 24.04 the easy way](https://www.cnx-software.com/2026/03/20/mediatek-mt7902-wifi-bluetooth-linux-ubuntu/)
- [Ask Fedora: MediaTek MT7902 Wireless LAN card](https://ask.fedoraproject.org/t/mediatek-mt7902-wireless-lan-card/2024)
- [Ask Ubuntu: MT7902 WiFi not working on Ubuntu 24.04](https://askubuntu.com/questions/mt7902-wifi-not-working-ubuntu-24-04)
- [Arch Linux forum thread (historical, now outdated)](https://bbs.archlinux.org/viewtopic.php?id=290808)

---

## Summary
- **MT7902 WiFi and Bluetooth are now easy to enable on modern Linux!**
- Use the backported driver for kernel 6.6–6.19, or wait for Linux 7.0+ for mainline support.
- PCIe modules are supported; SDIO may need further work.
- For older distributions or kernels, a USB WiFi dongle or card replacement was the only option.

---

*This document is up to date as of March 2026. If you discover further improvements, please update this file and share with the community!*
