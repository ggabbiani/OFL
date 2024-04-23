#!/bin/bash
#
# Docker entry-point for Fedora environments
#
# This file is part of the 'OpenSCAD Foundation Library' (OFL) project.
#
# Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later
#
source .venv/bin/activate
xvfb-run -d make SHELL="$(which bash)" -s -C /import "$@"
