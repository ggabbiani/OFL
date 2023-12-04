# Makefile for automatic test source generation
#
# This file is part of the 'OpenSCAD Foundation Library' (OFL) project.
#
# Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later

T_LIST			= box caddy-blob caddy pcb_frame pcb_holder spacer tnut tprofiles

SOURCES			= $(foreach t,$(T_LIST),$(t)-test.scad)
RESULTS			= $(foreach t,$(T_LIST),$(t)-test.echo)

include $(FUNCTIONS) $(DEF_RULES)

.PRECIOUS: $(SOURCES)

top:
	@$(MAKE) -C $(realpath ../..) tests/artifacts/sources

sources: $(SOURCES)

runs: clean-results $(RESULTS)

clean: clean-results
	@for f in $(SOURCES) ; do rm -f $$f ; done
	@echo "$(SOURCES): DELETED"

clean-results:
	@for f in $(RESULTS) ; do rm -rf $$f ; done
	@echo "$(RESULTS): DELETED"
