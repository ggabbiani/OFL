#!/usr/bin/env python3
#
# test execution helper for makefile usage
#
# This file is part of the 'OpenSCAD Foundation Library' (OFL) project.
#
# Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later
#

import argparse
import dotenv
import os
import re
import subprocess
import sys

import ofl

parser = argparse.ArgumentParser()
# parser.add_argument("test", type=str, help="test name")
parser.add_argument("-c", "--camera", help = "OpenSCAD camera position")
parser.add_argument("-d", "--dry-run", type=bool, help = "On screen dump only of the generated dot file",default=False)
parser.add_argument("test", type=str, help="Full test path WITHOUT SUFFIX")
parser.add_argument("-t", "--temp-root", type=str, help = "Temporary directory path", choices=["/var/tmp","/tmp"],default="/tmp")
parser.add_argument("-v", "--verbosity", type=int, help = "Increase verbosity", choices=[ofl.SILENT,ofl.ERROR,ofl.WARN,ofl.INFO,ofl.DEBUG],default=ofl.ERROR)
# Read arguments from command line
args = parser.parse_args()

ofl.verbosity   = args.verbosity

ofl.info("Camera        : % s" %args.camera)
ofl.info("Dry run       : % s" %args.dry_run)
ofl.info("OSCAD         : % s" %ofl.oscad)
ofl.info("Verbosity     : % s" %args.verbosity)

full    = os.path.normpath(args.test)
path    = os.path.dirname(full)
base    = os.path.basename(full)
conf    = os.path.join(path,base+'.conf')
json    = os.path.join(path,base+'.json')
scad    = os.path.join(path,base+'.scad')
echo    = os.path.join(path,base+'.echo')

ofl.debug("path : % s" %path)
ofl.debug("base : % s" %base)

camera = []
if args.camera:
    camera  = [args.camera]
elif os.path.isfile(conf):
    dict    = dotenv.dotenv_values(conf)
    for key in dict:
        if key=='CAMERA':
            camera  = [dict[key]]
if camera:
    camera = ['--camera'] + camera

oscad = ofl.oscad
if camera:
    oscad = ofl.oscad + camera
oscad = oscad + ["-o",echo,scad]

if os.path.isfile(json):
    ofl.debug(f"found JSON file {json}")
    f = open(json)
    lines = f.readlines()
    f.close()

    cases = []
    for l in lines:
        match   = re.findall('"TEST_CASE.*"\:',l)
        if match:
            print(match)
            # just one match for row so we take first occurrence
            # stripping first one (") and last two (":) characters
            cases.append(str(match[0])[1:-2])
    size = len(cases)
    if size:
        print(cases)
        ofl.debug(f"{size} TEST CONFIG(s) found in {json} file")
    else:
        ofl.debug(f"NO TEST CONFIG(s) found in {json} file")
else:
    ofl.debug(f"{json} file not found")

if args.dry_run:
    print(oscad)
else:
    result = subprocess.run(oscad,capture_output=True)
    print(result)
