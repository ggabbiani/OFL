# Makefile for automatic test source generation
#
# This file is part of the 'OpenSCAD Foundation Library' (OFL) project.
#
# Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later

# 'Lazy Set'
T_LIST		= blob-mount camera-mount Snapmaker-enclosure-handles spool-holder

include $(FUNCTIONS) $(DEF_RULES)

# 'Lazy Set'
PICS		= pic-blob-mount.png pic-camera-mount.png pic-Snapmaker-enclosure-handles.png pic-spool-holder.png

runs: $(PICS)

clean:
	$(call aggregate-prologue)
	@for f in $(PICS) ; do rm -fr $$f; done
	@rm -f *.deps
	$(call aggregate-epilogue)
