# This is intended to run on Linux/WSL
BINDIR=bin
BOOT_SECT=$(BINDIR)/boot_sect.bin
KERNEL=$(BINDIR)/kernel.bin
KERNEL_OBJ=$(BINDIR)/kernel.o
KERNEL_ENTRY=$(BINDIR)/kernel_entry.o
OS_IMG=$(BINDIR)/os-image

.DEFAULT_GOAL := all

all: setupdirs clean bin

bin: $(OS_IMG)

# This is the final disk image that will be booted
$(OS_IMG): $(BOOT_SECT) $(KERNEL)
	cat $^ > $@

$(KERNEL): $(KERNEL_ENTRY) $(KERNEL_OBJ)
	ld -o $@ -m elf_i386 -Ttext 0x1000 $^ --oformat binary

$(KERNEL_OBJ): kernel/kernel.c
	gcc -ffreestanding -m32 -fno-pie -c $< -o $@

$(KERNEL_ENTRY): kernel/kernel_entry.asm
	nasm $< -f elf32 -o $@

$(BOOT_SECT): boot/boot_sect.asm
	nasm $< -f bin -I boot -o $@

# Disassemble the kernel
disassemble: $(KERNEL)
	ndisasm -b 32 $< > $(BINDIR)/kernel.dis

# Run the OS in QEMU
run: run-qemu

run-qemu: setupdirs clean bin
	qemu-system-x86_64 -drive file=$(OS_IMG),format=raw,index=0,if=floppy -boot a -m 512

run-bochs: setupdirs clean bin
	bochs

# Initial project setup helper
setupdirs:
	@echo Creating project directories
	@if test -d $(BINDIR); then echo Re-using existing directory \'$(BINDIR)\' ; else mkdir $(BINDIR); fi

clean:
	@echo Cleaning previous build files
	@$(RM) -r $(BINDIR)/*
