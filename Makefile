# This is intended to run on Linux/WSL
# Define the compiler and the flags
CC = gcc
CFLAGS = -Wall -ffreestanding -m32 -fno-pie -c -o
LD = ld
LD_FLAGS = -m elf_i386 -Ttext 0x1000 --oformat binary -o
NASM = nasm

# Define the directories
KERNELDIR = kernel
DRIVERSDIR = drivers
BINDIR=bin
OBJDIR = $(BINDIR)

# Define the target files
BOOT_SECT=$(BINDIR)/boot_sect.bin
KERNEL=$(BINDIR)/kernel.bin
KERNEL_ENTRY=$(BINDIR)/kernel_entry.o
OS_IMG=$(BINDIR)/os-image

# Find all the source files in the kernel and drivers directories
KERNEL_SOURCES = $(wildcard $(KERNELDIR)/*.c)
DRIVERS_SOURCES = $(wildcard $(DRIVERSDIR)/*.c)
SOURCES = $(KERNEL_SOURCES) $(DRIVERS_SOURCES)

# Generate the names of the object files
KERNEL_OBJECTS = $(patsubst $(KERNELDIR)/%.c, $(OBJDIR)/kernel_%.o, $(KERNEL_SOURCES))
DRIVERS_OBJECTS = $(patsubst $(DRIVERSDIR)/%.c, $(OBJDIR)/drivers_%.o, $(DRIVERS_SOURCES))
OBJECTS = $(KERNEL_OBJECTS) $(DRIVERS_OBJECTS)

.DEFAULT_GOAL := all

all: setupdirs clean bin

bin: $(OS_IMG)

# Rule to compile kernel source files into object files
$(OBJDIR)/kernel_%.o: $(KERNELDIR)/%.c | $(OBJDIR)
	$(CC) $(CFLAGS) $@ $<

# Rule to compile drivers source files into object files
$(OBJDIR)/drivers_%.o: $(DRIVERSDIR)/%.c | $(OBJDIR)
	$(CC) $(CFLAGS) $@ $<

# This is the final disk image that will be booted
$(OS_IMG): $(BOOT_SECT) $(KERNEL)
	cat $^ > $@

$(KERNEL): $(KERNEL_ENTRY) $(OBJECTS)
	$(LD) $(LD_FLAGS) $@ $^

$(KERNEL_ENTRY): kernel/kernel_entry.asm
	$(NASM) $< -f elf32 -o $@

$(BOOT_SECT): boot/boot_sect.asm
	$(NASM) $< -f bin -I boot -o $@

# Disassemble the kernel
disassemble: $(KERNEL)
	ndisasm -b 32 $< > $(BINDIR)/kernel.dis

# Run the OS in QEMU
run: setupdirs clean bin
	qemu-system-x86_64 -drive file=$(OS_IMG),format=raw,index=0,if=floppy -boot a -m 512

# Initial project setup helper
setupdirs:
	@echo Creating project directories
	@if test -d $(BINDIR); then echo Re-using existing directory \'$(BINDIR)\' ; else mkdir $(BINDIR); fi

clean:
	@echo Cleaning previous build files
	@$(RM) -r $(BINDIR)/*
