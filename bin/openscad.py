#!/usr/bin/env python3
#
# until [issue #3616](https://github.com/openscad/openscad/issues/3616) is not
# applied to stable OpenSCAD branch we have to use a nightly build or check the
# command output with this wrapper.
#
# This file is part of the 'OpenSCAD Foundation Library' (OFL) project.
#
# Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later
#

import argparse
import os
import re

import ofl

from termcolor import colored, cprint

parser = argparse.ArgumentParser()
# options
parser.add_argument("--hardwarnings", action='store_true',default=False)
parser.add_argument("--dry-run", action='store_true')
parser.add_argument("-v", "--verbosity", type=int, help = "Increase verbosity", choices=[ofl.SILENT,ofl.ERROR,ofl.WARN,ofl.INFO,ofl.DEBUG],default=ofl.ERROR)
parser.add_argument("--ofl-script", type=str, help="OpenSCAD script",required=True)
parser.add_argument("--debug", action='store_true')

args, parms  = parser.parse_known_args()

ofl.verbosity   = args.verbosity

ofl.info("Verbosity : % s" %args.verbosity)
ofl.info("File      : % s" %args.ofl_script)
ofl.info("Parameters: % s" %parms)
ofl.info("Dry run   : % s" %args.dry_run)
ofl.info("hw        : % s" %args.hardwarnings)
ofl.info("quiet     : % s" %args.debug)

exit(ofl.openscad(args.ofl_script,quiet=not args.debug,parms=parms,hw=args.hardwarnings,dry_run=args.dry_run))
