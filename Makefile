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
export DEPS					:= $(PRJ_ROOT)/bin/deps.sh --silent
export BIN					:= $(CURDIR)/bin
export FUNCTIONS			:= $(CURDIR)/functions.mk
export SHELL				:= /bin/bash

include $(FUNCTIONS)

# function dependant variables
export SCAD					:= $(if $(call scad-path),$(BIN)/openscad.py -m make --view axes,$(error OpenSCAD missing))

# docs uses generated test scad files, so it's important to be executed AFTER
# tests creation
all: tests/sources docs/all orthodocs/all

clean: docs/clean orthodocs/clean tests/clean docker/clean

orthodocs/%: $(LIB_SOURCES)
	$(call make_sub)

docs/%:
	$(call make_sub)

tests/%:
	$(call make_sub)

docker/%: ALWAYS
	$(call make_sub)

# fake target forcing pattern rules that cannot be '.PHONY'
ALWAYS:
