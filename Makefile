CC=gcc
CFLAGS=-g -O2 -Wno-bitwise-op-parentheses -Wno-shift-op-parentheses
LDFLAGS=

SRC := $(wildcard *.c 3rdparty/*.c)
HDR := $(wildcard *.h 3rdparty/*.h)
SRC_LIB := $(filter $(patsubst %.h, %.c, $(HDR)), $(SRC))
SRC_BIN := $(filter-out $(SRC_LIB), $(SRC))

OBJ := $(patsubst %.c, obj/%.o, $(SRC_LIB))
BIN := $(patsubst %.c, bin/%, $(SRC_BIN))
TEST := $(patsubst %.c, test/%_test, $(SRC_LIB))

DEP = $(filter-out $(1), $(shell echo `tools/dep_dump $(1).c` `tools/dep_dump $(1).h` | xargs -n 1 | sort -u | xargs))
DEP_OBJ = $(patsubst %, obj/%.o, $(call DEP, $(1)))

TEST_MACRO = $(shell echo $(1) | tr a-z A-Z)_TEST
TEST_DEP_OBJ = $(filter-out $(patsubst %, obj/%.o, $(1)), $(OBJ))

all: $(OBJ) $(BIN) $(TEST)

$(OBJ): obj/%.o : $(call DEP_OBJ, %) %.c %.h
	$(CC) $(CFLAGS) $< -c -o $@
$(BIN): bin/% : $(call DEP_OBJ, %) %.c
	$(CC) $(CFLAGS) $(LDFLAGS) $< $(call DEP_OBJ, %) -o $@
$(TEST): test/%_test : $(call DEP_OBJ, %) %.c %.h
	$(CC) $(CFLAGS) $(LDFLAGS) $< $(call TEST_DEP_OBJ, $*) -o $@ -D $(call TEST_MACRO, $*)

.PHONY: clean
clean:
	find bin obj -type f | xargs rm -vf
	find . -name "*.dSYM" | xargs rm -rfv
	find . -name "#*#" | xargs rm -vf
	find . -name "*~" | xargs rm -vf

