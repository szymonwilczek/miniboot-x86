ASM = nasm
QEMU = qemu-system-x86_64

SRC_DIR = src
BUILD_DIR = build
TARGET = $(BUILD_DIR)/boot.bin

SRC = $(SRC_DIR)/boot.asm

.PHONY: all run clean

all: $(TARGET)

$(TARGET): $(SRC)
	@mkdir -p $(BUILD_DIR)
	$(ASM) -f bin $< -o $@

run: $(TARGET)
	$(QEMU) -drive format=raw,file=$(TARGET)

clean:
	rm -rf $(BUILD_DIR)
