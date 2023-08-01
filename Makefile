SRC_ROOT 	:= $(realpath .)
SRC_DIRS	:= artifacts foundation vitamins
LIB_SOURCES	:= $(wildcard $(SRC_ROOT)/*.scad) $(wildcard $(SRC_ROOT)/artifacts/*.scad) $(wildcard $(SRC_ROOT)/foundation/*.scad) $(wildcard $(SRC_ROOT)/vitamins/*.scad)
EXAMPLES	:= $(realpath examples)
TESTS		:= $(realpath tests)

export EXAMPLES LIB_SOURCES SRC_DIRS SRC_ROOT TESTS

.PHONY: pics

all: docs

clean:
	$(MAKE) -C pics $@

docs: api-docs pics

api-docs: $(LIB_SOURCES)
	$(MAKE) -C orthodocs
	$(MAKE) -C new-orthodocs

pics:
	$(MAKE) -C pics
