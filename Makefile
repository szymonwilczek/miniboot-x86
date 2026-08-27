ASM = nasm
ASMFLAGS = -f bin

BUILD_DIR = build
SRC_DIR = src

STAGE1_SRC = $(SRC_DIR)/stage1/boot.asm
STAGE2_SRC = $(SRC_DIR)/stage2/miniboot.asm

STAGE1_BIN = $(BUILD_DIR)/boot.bin
STAGE2_BIN = $(BUILD_DIR)/stage2.bin
TARGET_IMG = $(BUILD_DIR)/miniboot.img

.PHONY: all clean run

all: $(TARGET_IMG)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# Stage 1
$(STAGE1_BIN): $(STAGE1_SRC) | $(BUILD_DIR)
	$(ASM) $(ASMFLAGS) $< -o $@

# Stage 2
$(STAGE2_BIN): $(STAGE2_SRC) | $(BUILD_DIR)
	$(ASM) $(ASMFLAGS) $< -o $@

$(TARGET_IMG): $(STAGE1_BIN) $(STAGE2_BIN)
	dd if=/dev/zero of=$(TARGET_IMG) bs=512 count=2880
	dd if=$(STAGE1_BIN) of=$(TARGET_IMG) conv=notrunc
	dd if=$(STAGE2_BIN) of=$(TARGET_IMG) bs=512 seek=1 conv=notrunc

clean:
	rm -rf $(BUILD_DIR)

run: $(TARGET_IMG)
	qemu-system-x86_64 -drive format=raw,file=$(TARGET_IMG)
