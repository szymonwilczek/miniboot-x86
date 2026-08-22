ASM = nasm
QEMU = qemu-system-i386

SRC_DIR = src
BUILD_DIR = build
TARGET = $(BUILD_DIR)/boot.bin

MAIN_SRC = $(SRC_DIR)/boot.asm
ALL_SRCS = $(wildcard $(SRC_DIR)/*.asm)

.PHONY: all run clean

all: $(TARGET)

$(TARGET): $(ALL_SRCS)
	@mkdir -p $(BUILD_DIR)
	$(ASM) -f bin $(MAIN_SRC) -o $@

run: $(TARGET)
	$(QEMU) -drive format=raw,file=$(TARGET)

clean:
	rm -rf $(BUILD_DIR)
