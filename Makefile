BINDIR=bin
BOOT_SECT=$(BINDIR)/boot_sect.bin

.DEFAULT_GOAL := default

default: all

all: setupdirs clean bin

bin: $(BOOT_SECT)

$(BOOT_SECT): boot_sect.asm
	nasm boot_sect.asm -f bin -o $(BOOT_SECT)

run: run-qemu

run-qemu: setupdirs clean bin
	qemu-system-x86_64 -fda $(BOOT_SECT) -boot a -m 512

run-bochs: setupdirs clean bin
	bochs -f bochssrc

# Initial project setup helper
setupdirs:
	@echo Creating project directories
	@if test -d $(BINDIR); then echo Re-using existing directory \'$(BINDIR)\' ; else mkdir $(BINDIR); fi

clean:
	@echo Cleaning previous build files
	@$(RM) -r $(BINDIR)/*
