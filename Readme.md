# PR-DOS

Starting a rainy-day project to learn more about how computers work by [Writing a Simple Operating System from Scratch](./Writing%20a%20Simple%20Operating%20System%20from%20Scratch.pdf) by Nick Blundell.

## Notes

The boot sector is the first 512 bytes from Cylinder 0, Head 0, Sector 0 of the boot drive. It searches each of the bootable drives for one with the magic number `0xAA55` as the last two bytes of the boot sector. Note that the x86 architecture is little-endian, so the last two bytes are `0x55` and `0xAA`.

Intel compatible CPUs boot into *16-bit real mode* for backwards compatibility with the 8086 processor. It must then be switched to 32-bit or 64-bit protected mode.

The BIOS loads the boot sector to `0x7C00` in memory.

| Start memory addr | Description |
| --- | --- |
| 0x000000 | Real Mode IVT - Interrupt Vector Table (1 KB) |
| 0x000400 | BDA - BIOS Data Area (256 bytes) |
| 0x000500 | Conventional Memory (Free) (29 KB) |
| 0x007C00 | Loaded Boot Sector (512 bytes) |
| 0x007E00 | Conventional Memory (Free) (480 KB) |
| 0x09FC00 | EBDA - Extended BIOS Data Area (639 KB) |
| 0x0A0000 | Video Memory (128 KB) |
| 0x0C0000 | Video BIOS |
| 0x0C8000 | BIOS Expansions |
| 0x0F0000 | Motherboard BIOS |
| 0x100000 | Free |

## BIOS Interrupts

- [BIOS interrupt call - Wikipedia](https://en.wikipedia.org/wiki/BIOS_interrupt_call)
- [INT 10H - Wikipedia](https://en.wikipedia.org/wiki/INT_10H)
- [BIOS - OSDev Wiki](https://wiki.osdev.org/BIOS)

```asm
mov ah, 0x0e ; int 10/ah = 0eh -> scrolling teletype BIOS routine
mov al, ’H’  ; the character to output
int 0x10     ; call out to the interupt
```

## Compiling

Using `nasm`,

```sh
nasm boot_sect.asm -f bin -o boot_sect.bin
```

## Emulators

### Bochs

Available from [The Bochs IA-32 Emulator Project](https://bochs.sourceforge.io/). The file for the boot drive is configured using the file `bochsrc` in the current directory.

```sh
bochs
```

### QEmu

[QEme](https://www.qemu.org/) is a generic machine emulator and virtualizer. [x86 Documentation](https://wiki.qemu.org/Documentation/Platforms/PC)

```sh
qemu-system-x86_64 -fda boot_sect.bin -boot a -m 512
```

```sh
 qemu-system-i386 -hda <path to hd image file> -boot c -m 512 -soundhw ac97
 qemu-system-x86_64 -hda <path to hd image file> -boot c -m 512 -soundhw ac97
 ```
