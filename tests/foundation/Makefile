# Makefile for automatic test source generation
#
# This file is part of the 'OpenSCAD Foundation Library' (OFL) project.
#
# Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later

SOURCES			= 2d_grid-test.scad
RESULTS			= $(SOURCES:.scad=.echo)

include $(DEF_RULES)

.PRECIOUS: $(SOURCES)

tests: $(RESULTS)

clean:
	@for f in $(RESULTS) ; do rm -f $$f ; done
	@echo "$(RESULTS): DELETED"
	@for f in $(SOURCES) ; do rm -f $$f ; done
	@echo "$(SOURCES): DELETED"
