#
# Makefile for:
#
#   - pictures CREATION and CLEANUP for 'vitamins';
# 	- markdown documentation files CLEANUP ONLY.
#
# This file is part of the 'OpenSCAD Foundation Library' (OFL) project.
#
# Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later
#

top:
	@$(MAKE) -C $(realpath ../..) orthodocs/vitamins/all

include $(FUNCTIONS)

all: 256x256/all 400x800/all

256x256/%:
	$(call make_sub)

400x800/%:
	$(call make_sub)

clean:
	@rm -f *.md
	@$(MAKE) -C 256x256 $@
