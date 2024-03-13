# Makefile for automatic test source generation
#
# This file is part of the 'OpenSCAD Foundation Library' (OFL) project.
#
# Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later

T_LIST			= 2d 2d-ellipse 2d_grid 3d 3d_funcs algo assertions base_geo \
base_list base_string bend bend2 connect core-comparison core-symbols fillet \
hole label layout limits lists polymorphic profile square torus trace tube \
type_trait util

SOURCES			= $(foreach t,$(T_LIST),$(t)-test.scad)
RESULTS			= $(foreach t,$(T_LIST),$(t)-test.echo)

# $(info $$RESULTS is [${RESULTS}])

include $(FUNCTIONS) $(DEF_RULES)

.PRECIOUS: $(SOURCES)

top:
	@$(MAKE) -C $(realpath ../..) tests/foundation/sources

sources: $(SOURCES)

runs: clean-results $(RESULTS)

clean: clean-results
	@for f in $(SOURCES) ; do rm -f $$f ; done
	@echo "$(SOURCES): DELETED"

clean-results:
	@printf "\e[33m$@ [tests/foundation]\e[0m: "
	@for f in $(RESULTS) ; do rm -fr $$f ; done
	@printf "\e[32m✔\e[0m\n"
