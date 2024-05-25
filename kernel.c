// gcc -ffreestanding -m32 -c kernel.c -o bin/kernel.o
// ld -T NUL -o bin/kernel.tmp -Ttext 0x1000 -m i386pe bin/kernel.o
// objcopy -O binary -j .text  bin/kernel.tmp bin/kernel.bin
void __main()
{
    // Create a pointer to a char, and point it to the first text cell of video
    // memory (i.e. the top-left of the screen)
    char* video_memory = (char*) 0xb8000;
    // At the address pointed to by video_memory, store the character 'X'
    // (i.e. display 'X' in the top-left of the screen)
    *video_memory = 'X';
}
