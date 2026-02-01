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

# Attiva il virtual environment in modo che carichi TUTTE le variabili previste da Python
# Usiamo il punto (.) o source, è indifferente se lo shebang è bash
source /venv/bin/activate

xvfb-run -d make SHELL="$(which bash)" -s -C /import "$@"
