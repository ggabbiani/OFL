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
MAKEFLAGS += -s

# function dependant variables
# $(info SCAD path: $(call scad-path))
export SCAD		:= $(if $(call scad-path),$(BIN)/openscad.py -m make --view axes,$(warning WARN: OpenSCAD missing))
# $(info SCAD command: $(SCAD))
export WHICH 	:= $(if $(call is-win),where,which)
export IMVER 	:= $(shell convert --version 2>&1)
export IMCMD 	:= $(if $(findstring deprecated,$(IMVER)),$(shell $(WHICH) magick 2>/dev/null),$(shell $(WHICH) convert 2>/dev/null))
export WGET		:= $(shell $(call which) $(if $(call is-mac), curl,wget))

.PHONY: lib
.DEFAULT_GOAL := help

# docs uses generated test scad files, so it's important to be executed AFTER
# tests creation
all: check lib tests/sources docs/all orthodocs/all	## build lib prerequisites, test sources and the full documentation

clean: docs/clean examples/clean orthodocs/clean tests/clean-results docker/clean ## general cleanup, pre-req for docker test execution

check: ## preliminary checks
ifdef IMVER
	$(call msg-info,ImageMagick command found '$(IMCMD)')
else
	$(call msg-error,ImageMagick not found, please install)
endif
ifndef VIRTUAL_ENV
	$(call msg-error,Python Virtual Environment not active: type 'source .venv/bin/activate')
endif

orthodocs/%: $(LIB_SOURCES) ## type `make -s orthodocs/help`
	$(call make_sub)

docs/%:	## type `make -s docs/help`
	$(call make_sub)

examples/%: ## type `make -s examples/help`
	$(call make_sub)

tests/%: ## type `make -s tests/help`
	$(call make_sub)

docker/%: ALWAYS ## type `make -s docker/help`
	$(call make_sub)

lib: ALWAYS ## builds some library components dependent on third-party artifacts
	make -C lib/OFL/vitamins/ruthex

# fake target forcing pattern rules that cannot be '.PHONY'
ALWAYS:

help: ## Shows this help
	@grep -Eh '^[a-zA-Z0-9_/%. -]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'
