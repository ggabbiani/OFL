# Makefile for automatic test source generation
#
# This file is part of the 'OpenSCAD Foundation Library' (OFL) project.
#
# Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later

# 'Immediate Set'
TEMPLATE_DIR	:= $(CURDIR)
TEMPLATES		:= $(addprefix $(TEMPLATE_DIR)/,template-2d.scad template-3d.scad template-nogui.scad)
DEF_RULES		:= $(CURDIR)/defaults.mk
DEF_CONFS		:= $(CURDIR)/defaults.conf

# 'Lazy Set'
T_LIST			= bb error1 octant quadrant sgn switch warn1
SOURCES			= $(foreach t,$(T_LIST),$(t)-test.scad)
RESULTS			= $(foreach t,$(T_LIST),$(t)-test.echo)

export TEMPLATE_DIR TEMPLATES DEF_RULES DEF_CONFS

include $(FUNCTIONS) $(DEF_RULES)

.PRECIOUS: $(SOURCES)
.DEFAULT_GOAL := help

sources: $(SOURCES) artifacts/sources foundation/sources vitamins/sources	## create test sources on artifacts, foudation and vitamins

artifacts/%:	## type `make -s artifacts/help`
	$(call make_sub)

foundation/%:	## type `make -s foundation/help`
	$(call make_sub)

vitamins/%:		## type `make -s vitamins/help`
	$(call make_sub)

# clean-runs: clean-local $(RESULTS) artifacts/clean-runs foundation/clean-runs vitamins/clean-runs

clean-runs: clean-results runs	## clean previous results and trigger new tests

runs: $(RESULTS) artifacts/runs foundation/runs vitamins/runs	## trigger tests on artifacts, foudation and vitamins

clean-results: artifacts/clean-results foundation/clean-results vitamins/clean-results	## delete a test run result files
	$(call aggregate-prologue)
	@for f in $(RESULTS) ; do rm -fr $$f ; done
	$(call aggregate-epilogue)

clean-sources:	## delete test sources, sources will be rebuilt at first test run
	printf "$(COLOR_YELLOW)Cleaning tests sources? (Y/N):$(COLOR_RESET) "
	read -p "" confirm && [[ $$confirm == [yY] ]] || exit 1
	$(call aggregate-prologue)
	@for f in $(SOURCES) ; do rm -f $$f ; done
	$(call aggregate-epilogue)

help: ## Shows this help
	@grep -Eh '^[a-zA-Z0-9_/%. -]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'
