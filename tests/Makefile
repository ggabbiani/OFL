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
SOURCES			= bb-test.scad octant-test.scad quadrant-test.scad
RESULTS			= $(SOURCES:.scad=.echo)
OSCAD			= openscad --hardwarnings

export TEMPLATE_DIR TEMPLATES DEF_RULES DEF_CONFS OSCAD

include $(DEF_RULES)

.PRECIOUS: $(SOURCES)

tests: $(RESULTS) foundation

.PHONY: foundation

foundation:
	@$(MAKE) -C foundation tests

clean:
	@for f in $(RESULTS) ; do rm -f $$f ; done
	@echo "$(RESULTS): DELETED"
	@for f in $(SOURCES) ; do rm -f $$f ; done
	@echo "$(SOURCES): DELETED"
	@$(MAKE) -C foundation $@
