# Makefile for automatic test source generation
#
# This file is part of the 'OpenSCAD Foundation Library' (OFL) project.
#
# Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later

T_LIST			= countersinks ether generic hd hdmi heatsink iec jack \
knurl_nuts magnet pcb pcb_adapter pcb_custom pcb_frame pcb_import pcb_proxy \
pin_header psu sata sata-adapter screw sd spdt switch trimpot usb

SOURCES			= $(foreach t,$(T_LIST),$(t)-test.scad)
RESULTS			= $(foreach t,$(T_LIST),$(t)-test.echo)

include $(FUNCTIONS) $(DEF_RULES)

.PRECIOUS: $(SOURCES)

top:
	@$(MAKE) -C $(realpath ../..) tests/vitamins/sources

sources: $(SOURCES)

last: $(word $(words $(RESULTS)),$(RESULTS))

runs: clean-results $(RESULTS)

clean: clean-results
	@for f in $(SOURCES) ; do rm -f $$f ; done
	@echo "$(SOURCES): DELETED"

clean-results:
	@printf "\e[33m$@ [tests/vitamins]\e[0m: "
	@for f in $(RESULTS) ; do rm -fr $$f ; done
	@printf "\e[32m✔\e[0m\n"
