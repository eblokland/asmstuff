objects = build/main.o build/brainfuck.o build/read_file.o
.PHONY: clean

brainfuck: $(objects)
	$(CC) -o "$@" $^

build:
	mkdir build

build/%.o: %.s | build
	$(CC) -c -o "$@" "$<"

clean:
	rm -rf brainfuck build
