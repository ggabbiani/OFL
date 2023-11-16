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
OSCAD			= openscad --hardwarnings

export TEMPLATE_DIR TEMPLATES DEF_RULES DEF_CONFS OSCAD

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
	@for f in $(RESULTS) ; do rm -f $$f ; done
	@echo "$(RESULTS): DELETED"

clean: clean-results
	@for f in $(SOURCES) ; do rm -f $$f ; done
	@echo "$(SOURCES): DELETED"
	@$(MAKE) -C artifacts $@
	@$(MAKE) -C foundation $@
