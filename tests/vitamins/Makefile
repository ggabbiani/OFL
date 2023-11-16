# Makefile for automatic test source generation
#
# This file is part of the 'OpenSCAD Foundation Library' (OFL) project.
#
# Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later

T_LIST			= countersinks ether generic hd hdmi heatsink jack knurl_nuts \
magnet pcb pcb_adapter pcb_custom pcb_import pin_header psu sata sata-adapter \
screw sd spdt switch trimpot usb
SOURCES			= $(foreach t,$(T_LIST),$(t)-test.scad)
RESULTS			= $(foreach t,$(T_LIST),$(t)-test.echo)

include $(DEF_RULES)

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
	@for f in $(RESULTS) ; do rm -f $$f ; done
	@echo "$(RESULTS): DELETED"
