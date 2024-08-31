#!/usr/bin/env python3
#
# Fails if the command execution succeeds.
#
# NOTE: After the implementation of the --must-fail option in the OpenSCAD
# wrapper this command is useless.
#
# This file is part of the 'OpenSCAD Foundation Library' (OFL) project.
#
# Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later
#

import argparse, subprocess

import ofl

from termcolor import colored, cprint

parser = argparse.ArgumentParser()
# options
parser.add_argument("command", type=str, help="fail or success", choices=["fail","success"])
parser.add_argument("--dry-run", action='store_true')
parser.add_argument("-v", "--verbosity", type=int, help = "Increase verbosity", choices=[ofl.SILENT,ofl.ERROR,ofl.WARN,ofl.INFO,ofl.DEBUG],default=ofl.ERROR)
parser.add_argument("--quiet", action='store_true')

args, exec = parser.parse_known_args()

ofl.verbosity = args.verbosity

ofl.info("Verbosity : % s" %args.verbosity)
ofl.info("Command   : % s" %args.command)
ofl.info("Dry run   : % s" %args.dry_run)
ofl.info("Quiet     : % s" %args.quiet)
ofl.info("Exec      : % s" %exec)

if args.dry_run:
    exit(0)

result = subprocess.run(exec,stdout=subprocess.DEVNULL if args.quiet else None,stderr=subprocess.STDOUT if args.quiet else None) if not args.dry_run else 0

exit(0 if (args.command=="success" and result.returncode==0) or (args.command=="fail" and result.returncode!=0) else 1)
