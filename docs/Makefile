#
# This file is part of the 'OpenSCAD Foundation Library' (OFL) project.
#
# Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later
#

include $(FUNCTIONS)

.DEFAULT_GOAL := help

all: 800x600/all artifacts/all foundation/all vitamins/all	## create new documentation

clean: 800x600/clean artifacts/clean foundation/clean vitamins/clean ## clean current documentation

800x600/%:	## creates images 800x600 resolution
	$(call make_sub,800x600,"OFL/docs")

artifacts/%:	## create artifacts documentation
	$(call make_sub,artifacts,"OFL/docs")

foundation/%:	## create foundation documentation
	$(call make_sub,foundation,"OFL/docs")

vitamins/%:		## create vitamins documentation
	$(call make_sub,vitamins,"OFL/docs")

help: ## Shows this help
	@grep -Eh '^[a-zA-Z0-9_/%. -]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'
