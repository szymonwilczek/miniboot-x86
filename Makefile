ASM = nasm
QEMU = qemu-system-i386

SRC_DIR = src
BUILD_DIR = build
TARGET = $(BUILD_DIR)/boot.bin
SRC = $(SRC_DIR)/boot.asm

.PHONY: all run qemu-gdb clean

all: $(TARGET)

$(TARGET): $(SRC)
	@mkdir -p $(BUILD_DIR)
	$(ASM) -f bin $< -o $@

run: $(TARGET)
	$(QEMU) -drive format=raw,file=$(TARGET)

qemu-gdb: $(TARGET)
	$(QEMU) -drive format=raw,file=$(TARGET) -s -S

clean:
	rm -rf $(BUILD_DIR)
