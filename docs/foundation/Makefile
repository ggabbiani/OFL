#
# This file is part of the 'OpenSCAD Foundation Library' (OFL) project.
#
# Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later
#

include $(FUNCTIONS)

.DEFAULT_GOAL := help

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

help: ## Shows this help
	@grep -Eh '^[a-zA-Z0-9_/%. -]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'
