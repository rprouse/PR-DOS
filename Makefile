# This is intended to run on Windows
BINDIR=bin
BOOT_SECT=$(BINDIR)/boot_sect.bin
KERNEL=$(BINDIR)/kernel.bin
OS_IMG=$(BINDIR)/os-image

.DEFAULT_GOAL := default

default: all

all: setupdirs clean bin

bin: $(OS_IMG)

$(OS_IMG): $(BOOT_SECT) $(KERNEL)
	cat $(BOOT_SECT) $(KERNEL) > $(OS_IMG)

$(KERNEL): kernel.c
# Windows
	gcc -ffreestanding -m32 -c kernel.c -o bin/kernel.o
	ld -T NUL -o bin/kernel.tmp -Ttext 0x1000 -m i386pe bin/kernel.o
	objcopy -O binary -j .text  bin/kernel.tmp bin/kernel.bin
# Linux
#	gcc -ffreestanding -m32 -c kernel.c -o bin/kernel.o
#	ld -o bin/kernel.tmp -Ttext 0x1000 bin/kernel.o --oformat binary

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
