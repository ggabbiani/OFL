# Makefile for automatic test source generation
#
# This file is part of the 'OpenSCAD Foundation Library' (OFL) project.
#
# Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later

# 'Immediate Set'
DEF_RULES	:= $(CURDIR)/defaults.mk

# 'Lazy Set'
T_LIST		= bit-holder label-holder magnetic-key-holder sbc-box sliding-door-guide
SOURCES		= $(foreach t,$(T_LIST),$(t).scad)
RESULTS		= $(foreach t,$(T_LIST),$(t).echo)

export DEF_RULES

include $(FUNCTIONS) $(DEF_RULES)

.PRECIOUS: $(SOURCES)

sources: $(SOURCES) snapmaker/sources

snapmaker/%:
	$(call make_sub)

runs: clean-results $(RESULTS) snapmaker/runs

clean-results:
	$(call aggregate-prologue)
	@for f in $(RESULTS) ; do rm -fr $$f ; done
	$(call aggregate-epilogue)

clean: clean-results snapmaker/clean
	$(call aggregate-prologue)
	@for f in $(SOURCES) ; do rm -f $$f ; done
	$(call aggregate-epilogue)
#	@echo "$(SOURCES): DELETED"
