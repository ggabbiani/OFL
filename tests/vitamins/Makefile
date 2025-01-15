# Makefile for automatic test source generation
#
# This file is part of the 'OpenSCAD Foundation Library' (OFL) project.
#
# Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later

T_LIST	= countersinks ether fans generic hd hdmi heatsink iec jack knurl_nuts \
magnet pcb pcb_adapter pcb_custom pcb_frame pcb_import pcb_proxy pin_header \
psu sata sata-adapter screw sd spdt switch trimpot usb

SOURCES		= $(foreach t,$(T_LIST),$(t)-test.scad)
RESULTS		= $(foreach t,$(T_LIST),$(t)-test.echo)

include $(FUNCTIONS) $(DEF_RULES)

.PRECIOUS: $(SOURCES)

sources: $(SOURCES)

runs: clean-results $(RESULTS)

clean: clean-results
	$(call aggregate-prologue)
	@for f in $(SOURCES) ; do rm -f $$f ; done
	$(call aggregate-epilogue)

clean-results:
	$(call aggregate-prologue)
	@for f in $(RESULTS) ; do rm -fr $$f ; done
	$(call aggregate-epilogue)
