# Makefile for automatic test source generation
#
# This file is part of the 'OpenSCAD Foundation Library' (OFL) project.
#
# Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later

# 'Immediate Set'
TEMPLATE_DIR	:= $(CURDIR)
TEMPLATES		:= $(addprefix $(TEMPLATE_DIR)/,template-2d.scad template-3d.scad template-nogui.scad)
DEF_RULES		:= $(CURDIR)/defaults.mk
DEF_CONFS		:= $(CURDIR)/defaults.conf

# 'Lazy Set'
T_LIST			= bb octant quadrant
SOURCES			= $(foreach t,$(T_LIST),$(t)-test.scad)
RESULTS			= $(foreach t,$(T_LIST),$(t)-test.echo)

export TEMPLATE_DIR TEMPLATES DEF_RULES DEF_CONFS

include $(FUNCTIONS) $(DEF_RULES)

.PRECIOUS: $(SOURCES)

top:
	$(MAKE) -C $(realpath ..) tests/sources

sources: $(SOURCES) artifacts/sources foundation/sources vitamins/sources

artifacts/%:
	$(call make_sub)

foundation/%:
	$(call make_sub)

vitamins/%:
	$(call make_sub)

runs: clean-results $(RESULTS) artifacts/runs foundation/runs vitamins/runs

clean-results:
	@printf "\e[33m$@ [tests]\e[0m: "
	@for f in $(RESULTS) ; do rm -fr $$f ; done
	@printf "\e[32m✔\e[0m\n"

clean: clean-results artifacts/clean foundation/clean vitamins/clean
	@for f in $(SOURCES) ; do rm -f $$f ; done
	@echo "$(SOURCES): DELETED"
