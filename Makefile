# Makefile for automatic test and documentation generation
#
# This file is part of the 'OpenSCAD Foundation Library' (OFL) project.
#
# Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later

SRC_ROOT 	:= $(CURDIR)/lib
LIB_ROOT	:= $(SRC_ROOT)/OFL
LIB_DIRS	:= artifacts foundation vitamins
LIB_SOURCES	:= $(wildcard $(LIB_ROOT)/*.scad) $(wildcard $(LIB_ROOT)/artifacts/*.scad) $(wildcard $(LIB_ROOT)/foundation/*.scad) $(wildcard $(LIB_ROOT)/vitamins/*.scad)
LIB_SOURCES	:= $(wildcard $(addsuffix *.scad,$(LIB_DIRS)))
EXAMPLES	:= $(CURDIR)/examples
TESTS		:= $(CURDIR)/tests
TEMP_ROOT	:= /tmp

export EXAMPLES LIB_SOURCES LIB_DIRS SRC_ROOT LIB_ROOT TEMP_ROOT TESTS

.PHONY: pics tests

all: docs tests

tests:
	@$(MAKE) -C $(TESTS)

docs: api-docs pics

api-docs: $(LIB_SOURCES)
	@$(MAKE) -C orthodocs
	@$(MAKE) -C new-orthodocs

pics:
	@$(MAKE) -C pics

clean:
	@$(MAKE) -C pics $@
	@$(MAKE) -C $(TESTS) $@
