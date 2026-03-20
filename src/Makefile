# Makefile for Phase 5: MT7902 Firmware Loader Module

obj-m += phase5_mt7902_fw.o
phase5_mt7902_fw-objs := phase5-mt7902_fw_loader.o

KDIR := /lib/modules/6.14.0-37-generic/build
PWD := $(CURDIR)

.PHONY: all clean

all:
	@echo "KDIR is: $(KDIR)"
	$(MAKE) -C $(KDIR) M=$(PWD) modules

clean:
	$(MAKE) -C $(KDIR) M=$(PWD) clean

help:
	@echo "MT7902 Firmware Loader Module Build"
	@echo "===================================="
	@echo "make              - Build the module"
	@echo "make clean        - Clean build artifacts"
	@echo ""
	@echo "After building, load with:"
	@echo "  sudo insmod phase5_mt7902_fw.ko"
	@echo ""
	@echo "Check logs:"
	@echo "  dmesg | grep FW"
	@echo "or:"
	@echo "  journalctl -u kernel -f"

# Add debug symbols and fix stddef.h include path
EXTRA_CFLAGS += -O0 -g -I/usr/lib/gcc/x86_64-linux-gnu/13/include

# Disable module signature verification (workaround for Secure Boot)
CONFIG_MODULE_SIG = n
CONFIG_MODULE_SIG_ALL = n

.PHONY: load unload logs test

load:
	@echo "Loading module..."
	sudo insmod phase5_mt7902_fw.ko

unload:
	@echo "Unloading module..."
	sudo rmmod phase5_mt7902_fw || true

logs:
	@echo "Kernel logs (last 100 lines with [FW] marker):"
	sudo dmesg | grep "\[FW\]" | tail -100

logs-full:
	@echo "All kernel logs:"
	sudo dmesg | tail -200

test: all load logs

reload: unload load logs

