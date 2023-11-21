#
# This file is part of the 'OpenSCAD Foundation Library' (OFL) project.
#
# Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later
#

top:
	@$(MAKE) -C $(realpath ..) docs/all

include $(FUNCTIONS)

all: 800x600/all architecture.png artifacts/all foundation/all vitamins/all

clean: 800x600/clean artifacts/clean foundation/clean vitamins/clean
	@rm -f architecture.png

800x600/%:
	$(call make_sub,800x600,"OFL/docs")

artifacts/%:
	$(call make_sub,artifacts,"OFL/docs")

foundation/%:
	$(call make_sub,foundation,"OFL/docs")

vitamins/%:
	$(call make_sub,vitamins,"OFL/docs")

architecture.png: architecture.drawio
	@drawio --export --format png --border 10 --output $(CURDIR)/$@ $<
	@echo -n "$(CURDIR)/$@: "
	@echo -e "\e[32mOK\e[0m"

