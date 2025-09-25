ASM = nasm
ASM_FLAGS = -f elf64

TARGET = hexdump
ASMSOURCES = hexdump.asm hexlib.asm
OBJECTS = $(ASMSOURCES:.asm=.o)

all: $(TARGET)

$(TARGET): $(OBJECTS)
	@ld -o $(TARGET) $(OBJECTS)

%.o: %.asm
	@$(ASM) $(ASM_FLAGS) -o $@ $<
clean:
	@rm $(OBJECTS)
