#
# This file is part of the 'OpenSCAD Foundation Library' (OFL) project.
#
# Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later
#

top:
	@$(MAKE) -C $(realpath ../..) docs/foundation/all

include $(FUNCTIONS)

all: dependencies.svg 800x600/all

dependencies.svg: $(FOUNDATION_SOURCES)
	$(call target-prologue)
	@$(DEPS) --foundation
	$(call target-epilogue-success)

800x600/%:
	$(call make_sub,800x600)

clean:
	@$(MAKE) -C 800x600 $@
	@rm -f dependencies.svg
