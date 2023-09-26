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

include $(DEF_RULES)

.PRECIOUS: $(SOURCES)
.PHONY: artifacts artifacts-runs exported foundation foundation-runs tests vitamins vitamins-runs

sources: $(SOURCES) artifacts foundation vitamins

artifacts:
	@$(MAKE) -C $@

foundation:
	@$(MAKE) -C $@

vitamins:
	@$(MAKE) -C $@

runs: clean-results $(RESULTS) artifacts-runs foundation-runs vitamins-runs

clean-results:
	@for f in $(RESULTS) ; do rm -f $$f ; done
	@echo "$(RESULTS): DELETED"

artifacts-runs:
	@$(MAKE) -C artifacts runs

foundation-runs:
	@$(MAKE) -C foundation runs

vitamins-runs:
	@$(MAKE) -C vitamins runs

clean: clean-results
	@for f in $(SOURCES) ; do rm -f $$f ; done
	@echo "$(SOURCES): DELETED"
	@$(MAKE) -C artifacts $@
	@$(MAKE) -C foundation $@

# dump exported variables
exported:
	@echo DEF_CONFS=\'$(DEF_CONFS)\'
	@echo DEF_RULES=\'$(DEF_RULES)\'
	@echo OSCAD=\'$(OSCAD)\'
	@echo TEMPLATE_DIR=\'$(TEMPLATE_DIR)\'
	@echo TEMPLATES=\'$(TEMPLATES)\'
