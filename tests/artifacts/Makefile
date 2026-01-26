# Makefile for automatic test source generation
#
# This file is part of the 'OpenSCAD Foundation Library' (OFL) project.
#
# Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later

T_LIST			= box caddy-blob caddy din_rails joints pcb_holder profiles-engine spacer tnut tprofiles

SOURCES			= $(foreach t,$(T_LIST),$(t)-test.scad)
RESULTS			= $(foreach t,$(T_LIST),$(t)-test.echo)

include $(FUNCTIONS) $(DEF_RULES)

.PRECIOUS: $(SOURCES)
.DEFAULT_GOAL := help

sources: $(SOURCES)	## create test sources

runs: $(RESULTS)	## trigger tests on artifacts, foudation and vitamins

clean-results:	## delete a test run result files
	$(call aggregate-prologue)
	@for f in $(RESULTS) ; do rm -fr $$f ; done
	$(call aggregate-epilogue)

clean-sources:	## delete test sources, sources will be rebuilt at first test run
	printf "$(COLOR_YELLOW)Cleaning tests/artifacts sources? (Y/N):$(COLOR_RESET) "
	read -p "" confirm && [[ $$confirm == [yY] ]] || exit 1
	$(call aggregate-prologue)
	@for f in $(SOURCES) ; do rm -f $$f ; done
	$(call aggregate-epilogue)

help: ## Shows this help
	@grep -Eh '^[a-zA-Z0-9_/%. -]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'
