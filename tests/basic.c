// gcc -ffreestanding -m32 -c basic.c -o basic.o
// ld -T NUL -o basic.tmp -Ttext 0x1000 -m i386pe basic.o
// objcopy -O binary -j .text  basic.tmp basic.bin
int my_function() {
    int my_var = 0xDEAD;
    return my_var;
}
