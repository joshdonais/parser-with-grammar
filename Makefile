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
	./lex inputFiles/pass-test_1.txt test/pass-test_1.out
	./lex inputFiles/fail-test_1.txt test/fail-test_1.out
	@echo
	@echo --------------------
	@diff test/pass-test_1.ref test/pass-test_1.out
	@echo TEST SUCCESSFUL
	@echo

.PHONY: clean
clean:
	-rm lex 
	-rm *.ali *.o
	-rm b~*
	-rm test/test.out

.PHONY: e
e: clean all test
