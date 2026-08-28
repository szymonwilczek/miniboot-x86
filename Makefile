ASM = nasm
ASMFLAGS = -f bin

BUILD_DIR = build
SRC_DIR = src

STAGE1_SRC = $(SRC_DIR)/stage1/boot.asm
STAGE2_SRC = $(SRC_DIR)/stage2/miniboot.asm
INIT_SRC = $(SRC_DIR)/init

STAGE1_BIN = $(BUILD_DIR)/boot.bin
STAGE2_BIN = $(BUILD_DIR)/stage2.bin
KERNEL_BIN = $(BUILD_DIR)/bzImage
INITRD_BIN= $(BUILD_DIR)/initramfs.cpio.gz
TARGET_IMG = $(BUILD_DIR)/miniboot.img

.PHONY: all clean run

all: $(TARGET_IMG)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(KERNEL_BIN): | $(BUILD_DIR)
	cp $$(ls -t /boot/vmlinuz-* | head -n 1) $@

$(INITRD_BIN): $(INIT_SRC) | $(BUILD_DIR)
	rm -rf $(BUILD_DIR)/initramfs_tmp
	mkdir -p $(BUILD_DIR)/initramfs_tmp/{bin,sbin,usr/bin,usr/sbin,proc,sys,dev,etc,root}
	cp $$(which busybox) $(BUILD_DIR)/initramfs_tmp/bin/busybox
	chmod 755 $(BUILD_DIR)/initramfs_tmp/bin/busybox
	cd $(BUILD_DIR)/initramfs_tmp/bin && for a in $$(./busybox --list); do ln -sf busybox $$a; done
	cp $(INIT_SRC) $(BUILD_DIR)/initramfs_tmp/init
	chmod 755 $(BUILD_DIR)/initramfs_tmp/init
	cd $(BUILD_DIR)/initramfs_tmp && find . -print0 | cpio --null -ov --format=newc | gzip -9 > ../initramfs.cpio.gz
	rm -rf $(BUILD_DIR)/initramfs_tmp

# Stage 1
$(STAGE1_BIN): $(STAGE1_SRC) | $(BUILD_DIR)
	$(ASM) $(ASMFLAGS) $< -o $@

# Stage 2
$(STAGE2_BIN): $(STAGE2_SRC) | $(BUILD_DIR)
	$(ASM) $(ASMFLAGS) $< -o $@

$(TARGET_IMG): $(STAGE1_BIN) $(STAGE2_BIN) $(KERNEL_BIN) $(INITRD_BIN)
	dd if=/dev/zero of=$(TARGET_IMG) bs=1M count=64
	dd if=$(STAGE1_BIN) of=$(TARGET_IMG) conv=notrunc
	dd if=$(STAGE2_BIN) of=$(TARGET_IMG) bs=512 seek=1 conv=notrunc
	dd if=$(KERNEL_BIN) of=$(TARGET_IMG) bs=512 seek=17 conv=notrunc
	dd if=$(INITRD_BIN) of=$(TARGET_IMG) conv=notrunc bs=512 seek=45000

clean:
	rm -rf $(BUILD_DIR)

run: $(TARGET_IMG)
	qemu-system-x86_64 -drive format=raw,file=$(TARGET_IMG) -m 512M
