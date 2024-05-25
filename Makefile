# This is intended to run on Linux/WSL
BINDIR=bin
BOOT_SECT=$(BINDIR)/boot_sect.bin
KERNEL=$(BINDIR)/kernel.bin
KERNEL_OBJ=$(BINDIR)/kernel.o
KERNEL_ENTRY=$(BINDIR)/kernel_entry.o
OS_IMG=$(BINDIR)/os-image

.DEFAULT_GOAL := default

default: all

all: setupdirs clean bin

bin: $(OS_IMG)

$(OS_IMG): $(BOOT_SECT) $(KERNEL)
	cat $(BOOT_SECT) $(KERNEL) > $(OS_IMG)

$(KERNEL): $(KERNEL_ENTRY) $(KERNEL_OBJ)
	ld -o $(KERNEL) -m elf_i386 -Ttext 0x1000 $(KERNEL_ENTRY) $(KERNEL_OBJ) --oformat binary

$(KERNEL_OBJ): kernel.c
	gcc -ffreestanding -m32 -fno-pie -c kernel.c -o $(KERNEL_OBJ)

$(KERNEL_ENTRY): kernel_entry.asm
	nasm kernel_entry.asm -f elf32 -o $(KERNEL_ENTRY)

$(BOOT_SECT): boot_sect.asm
	nasm boot_sect.asm -f bin -o $(BOOT_SECT)

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
