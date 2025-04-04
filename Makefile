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
export COMMA				:= ,
export IMG_DIFF				:= $(BIN)/image-diff.py --threshold 99

include $(FUNCTIONS)

# function dependant variables
# $(info SCAD path: $(call scad-path))
export SCAD		:= $(if $(call scad-path),$(BIN)/openscad.py -m make --view axes,$(warning WARN: OpenSCAD missing))
# $(info SCAD command: $(SCAD))
export WHICH 	:= $(if $(call is-win),where,which)
export IMVER 	:= $(shell convert --version 2>&1)
export IMCMD 	:= $(if $(findstring deprecated,$(IMVER)),$(shell $(WHICH) magick 2>/dev/null),$(shell $(WHICH) convert 2>/dev/null))
export WGET		:= $(shell $(call which) $(if $(call is-mac), curl,wget))

.PHONY: lib

# docs uses generated test scad files, so it's important to be executed AFTER
# tests creation
all: check lib tests/sources docs/all orthodocs/all

clean: docs/clean examples/clean orthodocs/clean tests/clean docker/clean

check:
ifdef IMVER
	$(call msg-info,ImageMagick command found '$(IMCMD)')
else
	$(call msg-error,ImageMagick not found, please install)
endif

orthodocs/%: $(LIB_SOURCES)
	$(call make_sub)

docs/%:
	$(call make_sub)

examples/%:
	$(call make_sub)

tests/%:
	$(call make_sub)

docker/%: ALWAYS
	$(call make_sub)

lib: ALWAYS
	make -C lib/OFL/vitamins/ruthex

# fake target forcing pattern rules that cannot be '.PHONY'
ALWAYS:
