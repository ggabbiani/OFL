#
# Makefile for:
#
#   - pictures CREATION and CLEANUP for 'foundation';
# 	- markdown documentation files CLEANUP ONLY.
#
# This file is part of the 'OpenSCAD Foundation Library' (OFL) project.
#
# Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later
#

.DEFAULT_GOAL := help

include $(FUNCTIONS)

all: 256x256/all

256x256/%:
	$(call make_sub)

clean:
	@rm -f *.md
	@$(MAKE) -C 256x256 $@

help: ## Shows this help
	@grep -Eh '^[a-zA-Z0-9_/%. -]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'
