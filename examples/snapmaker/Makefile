# Makefile for automatic test source generation
#
# This file is part of the 'OpenSCAD Foundation Library' (OFL) project.
#
# Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later

# 'Lazy Set'
T_LIST		= blob-mount camera-mount Snapmaker-enclosure-handles spool-holder
SOURCES		= $(foreach t,$(T_LIST),$(t).scad)
RESULTS		= $(foreach t,$(T_LIST),$(t).echo)

include $(FUNCTIONS) $(DEF_RULES)

.PRECIOUS: $(SOURCES)

sources: $(SOURCES)

snapmaker/%:
	$(call make_sub)

runs: clean-results $(RESULTS)

clean-results:
	$(call aggregate-prologue)
	@for f in $(RESULTS) ; do rm -fr $$f ; done
	$(call aggregate-epilogue)

clean: clean-results snapmaker/clean
	$(call aggregate-prologue)
	@for f in $(SOURCES) ; do rm -f $$f ; done
	$(call aggregate-epilogue)
#	@echo "$(SOURCES): DELETED"
