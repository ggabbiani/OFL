# Makefile for automatic test source generation
#
# This file is part of the 'OpenSCAD Foundation Library' (OFL) project.
#
# Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later

# explicit wildcard expansion suppresses errors when no files are found
# include $(wildcard *.deps)

# %.png: %.scad
# 	openscad -m make -o $@ -d $@.deps $<

export OSCAD	:= openscad --hardwarnings
SOURCES			:= bb-test.scad octant-test.scad quadrant-test.scad
ECHOES			:= $(SOURCES:.scad=.echo)
export TEMPLATE	:= $(CURDIR)/test.template

# source creation
$(SOURCES): $(@:.scad=.base) $(@:.scad=.ini) $(TEMPLATE)
	@echo "creating $@"
	@((source ./$(@:.scad=.ini) && envsubst <$(TEMPLATE)) && cat $(@:.scad=.base)) >$@

# test execution
%.echo : %.scad
	@echo "testing $*.scad"
	@$(OSCAD) -o $*.echo $*.scad

.PHONY: foundation

# all: tests foundation

foundation:
	$(MAKE) -C foundation tests

tests: $(ECHOES) foundation

clean:
	for echo in $(ECHOES) ; do rm $$echo ; done
	for src in $(SOURCES) ; do rm $$src ; done
	$(MAKE) -C foundation $@
