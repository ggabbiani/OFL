#!/usr/bin/env python3
#
# picture creation helper for makefile usage
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

from termcolor import colored, cprint

def cat(f_name):
  print(open(f_name, 'r').read())

def prologue(title,case=None):
  if (case):
    print((colored(title+f" [{case}]: ", 'yellow')),end="",flush=True)
  else:
    print((colored(title+": ", 'yellow')),end="",flush=True)

def hires(lowres):
  res = [int(num)*8 for num in lowres.split('x')]
  return str(res[0])+','+str(res[1])

parser = argparse.ArgumentParser()
parser.add_argument("-c", "--camera", help = "OpenSCAD camera position")
parser.add_argument("-d", "--dry-run", action='store_true', help = "On screen dump only of the generated dot file")
parser.add_argument("-p", "--projection", help = "(o)rtho or (p)erspective when exporting png")
parser.add_argument("-t", "--temp-root", type=str, help = "Temporary directory path", choices=["/var/tmp","/tmp"],default="/tmp")
parser.add_argument("-v", "--verbosity", type=int, help = "Increase verbosity", choices=[ofl.SILENT,ofl.ERROR,ofl.WARN,ofl.INFO,ofl.DEBUG],default=ofl.ERROR)
parser.add_argument("--ofl-script", type=str, help="OpenSCAD script",required=True)
parser.add_argument("-r","--resolution",type=str,help="target resolution in 'openscad' format i.e. 800x600",required=True)
parser.add_argument("--render", action='store_true', help = "for full geometry evaluation when exporting png")
parser.add_argument("--viewall", action='store_true', help = "adjust camera to fit object")
parser.add_argument("--view", choices=['axes', 'crosshairs', 'edges', 'scales', 'wireframe'], help = "view options")
parser.add_argument("--make-deps", type=str, help = "make dependency file creation")

parser.add_argument("picture", type=str, help="Full target picture path")

args = parser.parse_args()

ofl.verbosity   = args.verbosity

ofl.info("Camera        : % s" %args.camera)
ofl.info("Projection    : % s" %args.projection)
ofl.info("Dry run       : % s" %args.dry_run)
ofl.info("OSCAD         : % s" %ofl.oscad)
ofl.info("Verbosity     : % s" %args.verbosity)
ofl.info("Resolution    : % s" %args.resolution)
ofl.info("View          : % s" %args.view)

full    = os.path.normpath(args.ofl_script.removesuffix('.scad'))
path    = os.path.dirname(full)
base    = os.path.basename(full)
conf    = os.path.join(path,base+'.conf')
json    = os.path.join(path,base+'.json')
scad    = os.path.join(path,base+'.scad')

ofl.debug("path : % s" %path)
ofl.debug("base : % s" %base)
ofl.debug("conf : % s" %conf)
ofl.debug("json : % s" %json)
ofl.debug("scad : % s" %scad)

full_target = os.path.normpath(args.picture.removesuffix('.png'))
target_path = os.path.dirname(full_target)
target_base = os.path.basename(full_target)
png         = os.path.join(target_path,'unscaled-'+target_base+'.png')

ofl.debug("target path: % s" %target_path)
ofl.debug("png        : % s" %png)

parms = ['--imgsize',hires(args.resolution),'-o',png]
if os.path.isfile(json):
  parms += ['--p',json,'--P',target_base]
if args.camera:
  parms += ['--camera', args.camera]
if args.projection:
  parms += ['--projection', args.projection]
if args.render:
  parms += ['--render']
if args.viewall:
  parms += ['--viewall']
if args.view:
  parms += ['--view', args.view]
if args.make_deps:
  parms += ['--m', 'make', '--d', args.make_deps]
echo    = os.path.join(args.temp_root,base+'.echo')
ofl.debug("command : % s" %parms)
ofl.debug("echo : % s" %echo)

result  = ofl.openscad(scad,parms=parms,echo_f=echo,hw=True,dry_run=args.dry_run)
if result.returncode!=0:
  cprint(f'✝ ({result.returncode})','red')
  cat(echo)
  exit(rc)