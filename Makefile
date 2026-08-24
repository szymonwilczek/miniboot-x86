ASM = nasm
ASMFLAGS = -f bin

BUILD_DIR = build
SRC_DIR = src

STAGE1_SRC = $(SRC_DIR)/stage1/boot.asm
STAGE2_SRC = $(SRC_DIR)/stage2/miniboot.asm

STAGE1_BIN = $(BUILD_DIR)/boot.bin
STAGE2_BIN = $(BUILD_DIR)/miniboot.bin
OS_IMG = $(BUILD_DIR)/miniboot.img

KERNEL_BIN = bzImage

.PHONY: all clean run

all: $(OS_IMG)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# Stage 1 (MBR - 512 bytes)
$(STAGE1_BIN): $(STAGE1_SRC) | $(BUILD_DIR)
	$(ASM) $(ASMFLAGS) -i $(SRC_DIR)/stage1/ $< -o $@

# Stage 2 (Miniboot Firmware Core)
$(STAGE2_BIN): $(STAGE2_SRC) $(shell find $(SRC_DIR)/stage2 -type f) | $(BUILD_DIR)
	$(ASM) $(ASMFLAGS) -i $(SRC_DIR)/stage2/ $< -o $@

# RAW Image
$(OS_IMG): $(STAGE1_BIN) $(STAGE2_BIN)
	# clear disk image
	dd if=/dev/zero of=$(OS_IMG) bs=1M count=64
	# upload stage 1 in LBA 0 (512 bytes)
	dd if=$(STAGE1_BIN) of=$(OS_IMG) bs=512 count=1 conv=notrunc
	# upload stage 2 in LBA 1
	dd if=$(STAGE2_BIN) of=$(OS_IMG) bs=512 seek=1 conv=notrunc
	# upload bzImage in LBA 64
	@if [ -f $(KERNEL_BIN) ]; then \
		dd if=$(KERNEL_BIN) of=$(OS_IMG) bs=512 seek=64 conv=notrunc; \
	fi

run: $(OS_IMG)
	qemu-system-x86_64 -drive format=raw,file=$(OS_IMG)

clean:
	rm -rf $(BUILD_DIR)
