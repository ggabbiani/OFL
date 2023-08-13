# Makefile for automatic test source generation
#
# This file is part of the 'OpenSCAD Foundation Library' (OFL) project.
#
# Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later

# 'Immediate Set'
export TEMPLATE		:= $(CURDIR)/template.scad
export DEF_RULES	:= $(CURDIR)/rules.mk

# 'Lazy Set'
SOURCES				= bb-test.scad octant-test.scad quadrant-test.scad
ECHOES				= $(SOURCES:.scad=.echo)
export OSCAD		= openscad --hardwarnings

include $(DEF_RULES)

tests: $(ECHOES) foundation

# source creation
$(SOURCES): $(@:.scad=.base) $(@:.scad=.conf) $(TEMPLATE)
	@echo "creating $@"
	@((set -a && source ./$(@:.scad=.conf) && envsubst <$(TEMPLATE)) && cat $(@:.scad=.base)) >$@

.PHONY: foundation

# all: tests foundation

foundation:
	$(MAKE) -C foundation tests

clean:
	@echo "Deleting $(ECHOES)"
	@for f in $(ECHOES) ; do rm -f $$f ; done
	@echo "Deleting $(SOURCES)"
	@for f in $(SOURCES) ; do rm -f $$f ; done
	@$(MAKE) -C foundation $@
