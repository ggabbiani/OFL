# Makefile for automatic test and documentation generation
#
# This file is part of the 'OpenSCAD Foundation Library' (OFL) project.
#
# Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later

PRJ_ROOT	:= $(realpath $(CURDIR)/..)
SRC_ROOT 	:= $(CURDIR)/lib
LIB_ROOT	:= $(SRC_ROOT)/OFL
LIB_DIRS	:= artifacts foundation vitamins
LIB_SOURCES	:= $(wildcard $(LIB_ROOT)/*.scad) $(wildcard $(LIB_ROOT)/artifacts/*.scad) $(wildcard $(LIB_ROOT)/foundation/*.scad) $(wildcard $(LIB_ROOT)/vitamins/*.scad)
EXAMPLES	:= $(CURDIR)/examples
TESTS		:= $(CURDIR)/tests
DOCS		:= $(CURDIR)/docs
TEMP_ROOT	:= /tmp

export EXAMPLES LIB_SOURCES LIB_DIRS LIB_ROOT PRJ_ROOT SRC_ROOT TEMP_ROOT TESTS

.PHONY: docs pics tests

all: api-docs docs pics tests

api-docs: $(LIB_SOURCES)
	@$(MAKE) -C orthodocs
	@$(MAKE) -C new-orthodocs

docs:
	@$(MAKE) -C $(DOCS)

pics:
	@$(MAKE) -C pics

tests:
	@$(MAKE) -C $(TESTS)

clean:
	@$(MAKE) -C pics $@
	@$(MAKE) -C $(TESTS) $@
	@$(MAKE) -C $(DOCS) $@
