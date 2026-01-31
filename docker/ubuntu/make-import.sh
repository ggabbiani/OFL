#!/bin/bash
#
# Docker entry-point for Ubuntu environments
#
# This file is part of the 'OpenSCAD Foundation Library' (OFL) project.
#
# Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later
#
xvfb-run -a make SHELL="$(which bash)" -s -C /import "$@"
