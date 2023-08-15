# Makefile for automatic test source generation
#
# This file is part of the 'OpenSCAD Foundation Library' (OFL) project.
#
# Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later

# 'Immediate Set'
export TEMPLATE_DIR	:= $(CURDIR)
export TEMPLATES	:= $(addprefix $(TEMPLATE_DIR)/,template-default.scad template-nogui.scad)
export DEF_RULES	:= $(CURDIR)/defaults.mk
export DEF_CONFS	:= $(CURDIR)/defaults.conf

# 'Lazy Set'
SOURCES				= bb-test.scad octant-test.scad quadrant-test.scad
RESULTS				= $(SOURCES:.scad=.echo)
export OSCAD		= openscad --hardwarnings

include $(DEF_RULES)

.PRECIOUS: $(SOURCES)

tests: $(RESULTS) foundation

.PHONY: foundation

foundation:
	$(MAKE) -C foundation tests

clean:
	@for f in $(RESULTS) ; do rm -f $$f ; done
	@echo "$(RESULTS): DELETED"
	@for f in $(SOURCES) ; do rm -f $$f ; done
	@echo "$(SOURCES): DELETED"
	@$(MAKE) -C foundation $@
