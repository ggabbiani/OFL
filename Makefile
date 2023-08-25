# This Makefile generates test and documentation files. This file is meant for
# maintainers, final users should not use it since the library is provided with
# tests and documentation already created.
#
# This file is part of the 'OpenSCAD Foundation Library' (OFL) project.
#
# Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later

PRJ_ROOT	:= $(realpath $(CURDIR))
SRC_ROOT 	:= $(CURDIR)/lib
LIB_ROOT	:= $(SRC_ROOT)/OFL
LIB_DIRS	:= artifacts foundation vitamins
ARTIFACTS_SOURCES	:= $(wildcard $(LIB_ROOT)/artifacts/*.scad)
VITAMINS_SOURCES	:= $(wildcard $(LIB_ROOT)/vitamins/*.scad)
FOUNDATION_SOURCES	:= $(wildcard $(LIB_ROOT)/foundation/*.scad)
LIB_SOURCES			:= $(wildcard $(LIB_ROOT)/*.scad) $(ARTIFACTS_SOURCES) $(FOUNDATION_SOURCES) $(VITAMINS_SOURCES)
EXAMPLES	:= $(CURDIR)/examples
TESTS		:= $(CURDIR)/tests
DOCS		:= $(CURDIR)/docs
TEMP_ROOT	:= /tmp
SCAD		:= OPENSCADPATH="$(SRC_ROOT):${OPENSCADPATH}" openscad -m make --view axes
DEPS		:= $(PRJ_ROOT)/bin/deps.sh --silent

export DEPS EXAMPLES LIB_SOURCES LIB_DIRS LIB_ROOT PRJ_ROOT SCAD SRC_ROOT TEMP_ROOT TESTS

.PHONY: docs tests

all: api-docs docs tests

api-docs: $(LIB_SOURCES)
	@$(MAKE) -C orthodocs all
	@$(MAKE) -C new-orthodocs

docs:
	@$(MAKE) -C $(DOCS)

tests:
	@$(MAKE) -C $(TESTS)

clean: docs-clean tests-clean

docs-clean:
	@$(MAKE) -C $(DOCS) clean
	@$(MAKE) -C orthodocs clean

tests-clean:
	@$(MAKE) -C $(TESTS) clean
