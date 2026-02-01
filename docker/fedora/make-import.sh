#!/bin/bash
#
# Docker entry-point for Fedora environments. The git repo is meant to be set
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

# We use GITHUB_WORKSPACE just as a 'hint', if it exists we use it, if not
# let's bet on '/import'. If /import doesn't exist either, then rise an error.
TARGET_DIR="${GITHUB_WORKSPACE:-/import}"
if [ ! -d "$TARGET_DIR" ]; then
    echo "Either GITHUB_WORKSPACE or target directory \"${TARGET_DIR}\" doesn't exist."
    exit 5
fi
xvfb-run -d make SHELL="$(which bash)" -s -C "${TARGET_DIR}" "$@"
