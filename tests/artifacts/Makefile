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

# $(info SOURCES=$(SOURCES))

include $(FUNCTIONS) $(DEF_RULES)

.PRECIOUS: $(SOURCES)

sources: $(SOURCES)

# clean-runs: clean-local $(RESULTS)

runs: $(RESULTS)

clean-results:
	$(call aggregate-prologue)
	@for f in $(RESULTS) ; do rm -fr $$f ; done
	$(call aggregate-epilogue)

clean-sources:
	printf "$(COLOR_YELLOW)Cleaning tests/artifacts sources? (Y/N):$(COLOR_RESET) "
	read -p "" confirm && [[ $$confirm == [yY] ]] || exit 1
	$(call aggregate-prologue)
	@for f in $(SOURCES) ; do rm -f $$f ; done
	$(call aggregate-epilogue)