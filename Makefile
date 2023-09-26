# This Makefile generates test and documentation files. This file is meant for
# maintainers, final users should not use it since the library is provided with
# tests and documentation already created.
#
# This file is part of the 'OpenSCAD Foundation Library' (OFL) project.
#
# Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later

export PRJ_ROOT				:= $(realpath $(CURDIR))
export SRC_ROOT 			:= $(CURDIR)/lib
export LIB_ROOT				:= $(SRC_ROOT)/OFL
export LIB_DIRS				:= artifacts foundation vitamins
export ARTIFACTS_SOURCES	:= $(wildcard $(LIB_ROOT)/artifacts/*.scad)
export VITAMINS_SOURCES		:= $(wildcard $(LIB_ROOT)/vitamins/*.scad)
export FOUNDATION_SOURCES	:= $(wildcard $(LIB_ROOT)/foundation/*.scad)
export LIB_SOURCES			:= $(wildcard $(LIB_ROOT)/*.scad) $(ARTIFACTS_SOURCES) $(FOUNDATION_SOURCES) $(VITAMINS_SOURCES)
export EXAMPLES				:= $(CURDIR)/examples
export TESTS				:= $(CURDIR)/tests
export DOCS					:= $(CURDIR)/docs
export TEMP_ROOT			:= /tmp
export SCAD					:= OPENSCADPATH="$(SRC_ROOT):${OPENSCADPATH}" openscad -m make --view axes
export DEPS					:= $(PRJ_ROOT)/bin/deps.sh --silent
export BIN					:= $(CURDIR)/bin

.PHONY: docs exported exports tests

# docs uses generated test scad files, so it's important to be executed AFTER
# tests creation
all: api-docs tests docs

api-docs: $(LIB_SOURCES)
	@$(MAKE) -C orthodocs all
#	@$(MAKE) -C new-orthodocs

docs:
	@$(MAKE) -C $(DOCS)

tests:
	@$(MAKE) -C $(TESTS)

test-runs:
	@$(MAKE) -C $(TESTS) runs

clean: docs-clean tests-clean

docs-clean:
	@$(MAKE) -C $(DOCS) clean
	@$(MAKE) -C orthodocs clean

tests-clean:
	@$(MAKE) -C $(TESTS) clean

# dump exported variables
exported:
	@echo ARTIFACTS_SOURCES=\'$(ARTIFACTS_SOURCES)\'
	@echo BIN=\'$(BIN)\'
	@echo DEPS=\'$(DEPS)\'
	@echo DOCS=\'$(DOCS)\'
	@echo EXAMPLES=\'$(EXAMPLES)\'
	@echo FOUNDATION_SOURCES=\'$(FOUNDATION_SOURCES)\'
	@echo LIB_DIRS=\'$(LIB_DIRS)\'
	@echo LIB_ROOT=\'$(LIB_ROOT)\'
	@echo LIB_SOURCES=\'$(LIB_SOURCES)\'
	@echo PRJ_ROOT=\'$(PRJ_ROOT)\'
	@echo SCAD=\'$(SCAD)\'
	@echo SRC_ROOT=\'$(SRC_ROOT)\'
	@echo TEMP_ROOT=\'$(TEMP_ROOT)\'
	@echo TESTS=\'$(TESTS)\'
	@echo VITAMINS_SOURCES=\'$(VITAMINS_SOURCES)\'
