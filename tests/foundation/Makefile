# Makefile for automatic test source generation
#
# This file is part of the 'OpenSCAD Foundation Library' (OFL) project.
#
# Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later

SOURCES			= 2d_grid-test.scad
ECHOES			= $(SOURCES:.scad=.echo)

include $(DEF_RULES)

# source creation
$(SOURCES): $(@:.scad=.base) $(@:.scad=.conf) $(TEMPLATE)
	@echo "creating $@"
	@((set -a && source ./$(@:.scad=.conf) && envsubst <$(TEMPLATE)) && cat $(@:.scad=.base)) >$@

# # test execution
# %.echo : %.scad
# 	@echo "testing $*.scad"
# 	@$(OSCAD) -o $*.echo $*.scad

.PHONY: tests

tests: $(ECHOES)
	@echo "Echoes: $(ECHOES)"
	@echo "Default rules: $(DEF_RULES)"

clean:
	@echo "Deleting $(ECHOES)"
	@for f in $(ECHOES) ; do rm -f $$f ; done
	@echo "Deleting $(SOURCES)"
	@for f in $(SOURCES) ; do rm -f $$f ; done
