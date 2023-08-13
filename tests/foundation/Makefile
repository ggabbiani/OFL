# Makefile for automatic test source generation
#
# This file is part of the 'OpenSCAD Foundation Library' (OFL) project.
#
# Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later

# export OSCAD	:= openscad --hardwarnings
SOURCES			:= 2d_grid-test.scad
ECHOES			:= $(SOURCES:.scad=.echo)
# TEMPLATE		:= $(realpath ../test.template)

# source creation
$(SOURCES): $(@:.scad=.base) $(@:.scad=.ini) $(TEMPLATE)
	@echo "creating $@"
	@((source ./$(@:.scad=.ini) && envsubst <$(TEMPLATE)) && cat $(@:.scad=.base)) >$@

# test execution
%.echo : %.scad
	@echo "testing $*.scad"
	@$(OSCAD) -o $*.echo $*.scad

tests: $(ECHOES)

clean:
	for echo in $(ECHOES) ; do rm $$echo ; done
	for src in $(SOURCES) ; do rm $$src ; done
