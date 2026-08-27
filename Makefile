ASM = nasm
ASMFLAGS = -f bin

BUILD_DIR = build
SRC_DIR = src/stage1

TARGET_BIN = $(BUILD_DIR)/boot.bin
TARGET_IMG = $(BUILD_DIR)/miniboot.img

.PHONY: all clean run

all: $(TARGET_IMG)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(TARGET_BIN): $(SRC_DIR)/boot.asm | $(BUILD_DIR)
	$(ASM) $(ASMFLAGS) $< -o $@

$(TARGET_IMG): $(TARGET_BIN)
	dd if=/dev/zero of=$(TARGET_IMG) bs=512 count=2880
	dd if=$(TARGET_BIN) of=$(TARGET_IMG) conv=notrunc

clean:
	rm -rf $(BUILD_DIR)

run: $(TARGET_IMG)
	qemu-system-x86_64 -drive format=raw,file=$(TARGET_IMG)
