CC=gnatmake
CFLAGS= -g

SOURCES = \
	src/lex.adb
EXECUTABLE = \build/lex

.PHONY: all
all: build $(EXECUTABLE)

$(EXECUTABLE): $(SOURCES)
	$(CC) $(CFLAGS) src/lex.adb $(EXECUABLE)

build:
	@mkdir -p build

.PHONY: documentation
documentation: $(SOURCES)

.PHONY: test
test: lex
	./lex abc.txt abcOut.txt
	./lex test1.txt test1Out.txt


.PHONY: clean
clean:
	-rm lex 
	-rm *.ali *.o
	-rm b~*
	-rm abcOut.txt

