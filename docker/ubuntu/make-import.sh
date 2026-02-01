#!/bin/bash
#
# Docker entry-point for Ubuntu environments. The git repo is meant to be set
# in GITHUB_WORKSPACE environment variable.
#
# This file is part of the 'OpenSCAD Foundation Library' (OFL) project.
#
# Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later
#

source /venv/bin/activate

echo "GITHUB_WORKSPACE=${GITHUB_WORKSPACE}"
xvfb-run -a make SHELL="$(which bash)" -s -C "${GITHUB_WORKSPACE}" "$@"
