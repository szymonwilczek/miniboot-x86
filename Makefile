ASM = nasm
ASMFLAGS = -f bin

BUILD_DIR = build
SRC_DIR = src

STAGE1_SRC = $(SRC_DIR)/stage1/boot.asm
STAGE2_SRC = $(SRC_DIR)/stage2/miniboot.asm

STAGE1_BIN = $(BUILD_DIR)/boot.bin
STAGE2_BIN = $(BUILD_DIR)/miniboot.bin
OS_IMG = $(BUILD_DIR)/miniboot.img

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

# Stage 1 + Stage 2
$(OS_IMG): $(STAGE1_BIN) $(STAGE2_BIN)
	cat $(STAGE1_BIN) $(STAGE2_BIN) > $(OS_IMG)
	truncate -s 1440k $(OS_IMG)

run: $(OS_IMG)
	qemu-system-x86_64 -drive format=raw,file=$(OS_IMG)

clean:
	rm -rf $(BUILD_DIR)
