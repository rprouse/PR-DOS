# PR-DOS

A rainy-day project to learn more about how computers work by writing an operating system. I started with [Writing a Simple Operating System from Scratch](https://www.cs.bham.ac.uk/~exr/lectures/opsys/10_11/lectures/os-dev.pdf) by Nick Blundell, but the paper is an incomplete draft and hasn't been updated since 2010. I've since moved on to following [Building an OS](https://www.youtube.com/watch?v=9t-SPC7Tczc&list=PLFjM7v6KGMpiH2G-kT781ByCNC_0pKpPN) by nanobyte.

Other resources, [OSDev wiki](http://wiki.osdev.org/), [The little book about OS development](https://littleosbook.github.io), and [JamesM's kernel development tutorials](https://web.archive.org/web/20160412174753/http://www.jamesmolloy.co.uk/tutorial_html/index.html)

## Notes

- [Intel 80386 Reference Programmer's Manual](https://pdos.csail.mit.edu/6.828/2018/readings/i386/toc.htm)
- [x86 Assembly Programming - WikiBooks](https://en.wikibooks.org/wiki/X86_Assembly)

The boot sector is the first 512 bytes from Cylinder 0, Head 0, Sector 0 of the boot drive. It searches each of the bootable drives for one with the magic number `0xAA55` as the last two bytes of the boot sector. Note that the x86 architecture is little-endian, so the last two bytes are `0x55` and `0xAA` (`0xAA55` little endian).

Once a bootable sector is found, the BIOS loads the 512 byte boot sector to `0x7C00` in memory and begins executing at that location.

Intel compatible CPUs boot into *16-bit real mode* for backwards compatibility with the 8086 processor. It must then be switched to 32-bit or 64-bit protected mode.

## X86/x64 Assembly

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

### Segment Registers

| Register | Description |
| --- | --- |
| cs | Code segment |
| ds | Data segment |
| ss | Stack segment |
| es | Extra data segment |
| fs | F segment |
| gs | G segment |

To calculate the absolute address, the CPU multiplies the value in the segment register by 16 and then adds it to your offset address. Multiplying by 16 in Hex effectively shifts the value left one nibble, so if `ds = 0x5E` then the offset would be `0x5E0`.

## BIOS Interrupts

- [BIOS interrupt call - Wikipedia](https://en.wikipedia.org/wiki/BIOS_interrupt_call)
- [INT 10H - Wikipedia](https://en.wikipedia.org/wiki/INT_10H)
- [BIOS - OSDev Wiki](https://wiki.osdev.org/BIOS)

```asm
mov ah, 0x0e ; int 10/ah = 0eh -> scrolling teletype BIOS routine
mov al, ’H’  ; the character to output
int 0x10     ; call out to the interupt
```

## Required Software

I started out developing using `gcc` on Windows, but the easiest tools to use are Linux based, so I've switched to developing in Ubuntu in WSL.

- `nasm`, the [Netwide Assembler](https://www.nasm.us/)
- [QEmu](https://www.qemu.org/) is a generic machine emulator and virtualizer. [x86 Documentation](https://wiki.qemu.org/Documentation/Platforms/PC).

```sh
sudo apt update
sudo apt install build-essential nasm qemu-system genisoimage
```

## QEmu

[QEmu](https://www.qemu.org/) is a generic machine emulator and virtualizer. [x86 Documentation](https://wiki.qemu.org/Documentation/Platforms/PC).

Install on Linux,

```sh
sudo apt-get install qemu-system
```

Install on Windows,

```sh
winget install --id SoftwareFreedomConservancy.QEMU
```

Then add `C:\Program Files\qemu` to your `PATH`.

Run with,

```sh
qemu-system-x86_64 -fda boot_sect.bin -boot a -m 512
qemu-system-x86_64 -drive file=boot_sect.bin,format=raw,index=0,if=floppy -boot a -m 512
```

```sh
 qemu-system-i386 -hda <path to hd image file> -boot c -m 512 -soundhw ac97
 qemu-system-x86_64 -hda <path to hd image file> -boot c -m 512 -soundhw ac97
 ```
