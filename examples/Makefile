# Makefile for automatic example tests
#
# This file is part of the 'OpenSCAD Foundation Library' (OFL) project.
#
# Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later

# 'Immediate Set'
DEF_RULES	:= $(CURDIR)/defaults.mk

# explicit wildcard expansion suppresses errors when no files are found
include $(wildcard *.deps) $(FUNCTIONS) $(DEF_RULES)

# 'Lazy Set'
PICS		= pic-bit-holder.png pic-magnetic-key-holder.png

export DEF_RULES

runs: $(PICS) snapmaker/runs

snapmaker/%:
	$(call make_sub)

clean: snapmaker/clean
	$(call aggregate-prologue)
	@for f in $(PICS) ; do rm -fr $$f ; done
	@rm *.deps
	$(call aggregate-epilogue)
