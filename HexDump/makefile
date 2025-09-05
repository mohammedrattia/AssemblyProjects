filename = hexdump
hexdump: ${filename}.o
	@ld -o ${filename} ${filename}.o
hexdump.o:
	@nasm -f elf64 -g -F stabs ${filename}.asm
clean:
	@rm ${filename}.o
