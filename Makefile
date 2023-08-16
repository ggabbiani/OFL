# Makefile for automatic test and documentation generation
#
# This file is part of the 'OpenSCAD Foundation Library' (OFL) project.
#
# Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later

SRC_ROOT 	:= $(realpath .)
SRC_DIRS	:= artifacts foundation vitamins
LIB_SOURCES	:= $(wildcard $(SRC_ROOT)/*.scad) $(wildcard $(SRC_ROOT)/artifacts/*.scad) $(wildcard $(SRC_ROOT)/foundation/*.scad) $(wildcard $(SRC_ROOT)/vitamins/*.scad)
EXAMPLES	:= $(realpath examples)
TESTS		:= $(realpath tests)

export EXAMPLES LIB_SOURCES SRC_DIRS SRC_ROOT TESTS

.PHONY: pics tests

all: docs tests tests

tests:
	@$(MAKE) -C tests

docs: api-docs pics

api-docs: $(LIB_SOURCES)
	@$(MAKE) -C orthodocs
	@$(MAKE) -C new-orthodocs

pics:
	@$(MAKE) -C pics

clean:
	@$(MAKE) -C pics $@
	@$(MAKE) -C tests $@
