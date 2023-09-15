# Makefile for automatic test source generation
#
# This file is part of the 'OpenSCAD Foundation Library' (OFL) project.
#
# Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later

SOURCES			= 2d_grid-test.scad 2d-test.scad 3d-test.scad 3d_funcs-test.scad algo-test.scad \
assertions-test.scad base_geo-test.scad base_string-test.scad bend-test.scad bend2-test.scad
RESULTS			= $(SOURCES:.scad=.echo)

include $(DEF_RULES)

.PRECIOUS: $(SOURCES)

tests: $(RESULTS)

clean:
	@for f in $(RESULTS) ; do rm -f $$f ; done
	@echo "$(RESULTS): DELETED"
	@for f in $(SOURCES) ; do rm -f $$f ; done
	@echo "$(SOURCES): DELETED"
