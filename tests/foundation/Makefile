# Makefile for automatic test source generation
#
# This file is part of the 'OpenSCAD Foundation Library' (OFL) project.
#
# Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later

T_LIST			= 2d 2d-ellipse 2d_grid 3d 3d_funcs algo assertions base_geo \
base_list base_string bend bend2 connect core-comparison core-symbols \
dimensions extrusion fillet frame hole label layout limits lists polymorphic \
square torus trace tube traits-engine util vdp

SOURCES			= $(foreach t,$(T_LIST),$(t)-test.scad)
RESULTS			= $(foreach t,$(T_LIST),$(t)-test.echo)

# $(info $$RESULTS is [${RESULTS}])

include $(FUNCTIONS) $(DEF_RULES)

.PRECIOUS: $(SOURCES)

top:
	@$(MAKE) -C $(realpath ../..) tests/foundation/sources

sources: $(SOURCES)

# clean-runs: clean-local $(RESULTS)

runs: $(RESULTS)

clean-results:
	$(call aggregate-prologue)
	@for f in $(RESULTS) ; do rm -fr $$f ; done
	$(call aggregate-epilogue)

clean-sources:
	printf "$(COLOR_YELLOW)Cleaning tests/foundation sources? (Y/N):$(COLOR_RESET) "
	read -p "" confirm && [[ $$confirm == [yY] ]] || exit 1
	$(call aggregate-prologue)
	@for f in $(SOURCES) ; do rm -f $$f ; done
	$(call aggregate-epilogue)