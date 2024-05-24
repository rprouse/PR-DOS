// gcc -ffreestanding -m32 -c basic.c -o basic.o
// ld -T NUL -o basic.tmp -Ttext 0x1000 -m i386pe basic.o
// objcopy -O binary -j .text  basic.tmp basic.bin
int callee_function(int my_arg) {
    return my_arg;
}

void caller_function() {
    callee_function(0xDEAD);
}
