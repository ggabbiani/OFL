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

from termcolor import colored, cprint

def get_camera(arg,file):
  result = []
  if arg:
    result  = [arg]
  elif os.path.isfile(conf):
    dict    = dotenv.dotenv_values(conf)
    for key in dict:
      if key=='CAMERA':
        result  = [dict[key]]
  return ['--camera'] + result if result else []

def test_cases(lines):
  result = []
  for line in lines:
    match   = re.findall('"TEST_CASE.*":',line)
    if match:
      # just one match for row so we take first occurrence
      # stripping first one (") and last two (":) characters
      result.append(str(match[0])[1:-2])
  return result

def cat(f_name):
  print(open(f_name, 'r').read())

def run(base,test,output,dry_run=False,case=None):
  test_cmd = test + ['-o', output]
  if dry_run:
    print(test_cmd)
    return 0
  else:
    if (case):
      print((colored(base+f" [{case}]: ", 'yellow')),end="",flush=True)
    else:
      print((colored(base+": ", 'yellow')),end="",flush=True)
    result = subprocess.run(test_cmd)
    if result.returncode==0:
      lines = ofl.read_lines(output)
      # until [issue #3616](https://github.com/openscad/openscad/issues/3616) is not
      # applied to stable OpenSCAD branch we have to use a nightly build or check the
      # command output
      for line in lines:
        match   = re.findall('^WARNING:',line)
        if match:
          cprint(f'✝','red')
          return -1
      cprint('✔','green')
      return 0
    else:
      cprint(f'✝ ({result.returncode})','red')
      return result.returncode

def echo(path,base):
  return os.path.join(path,base+'.echo')

parser = argparse.ArgumentParser()
parser.add_argument("-c", "--camera", help = "OpenSCAD camera position")
parser.add_argument("-d", "--dry-run", action='store_true', help = "On screen dump only of the generated dot file")
parser.add_argument("test", type=str, help="Full test path WITHOUT SUFFIX")
parser.add_argument("-t", "--temp-root", type=str, help = "Temporary directory path", choices=["/var/tmp","/tmp"],default="/tmp")
parser.add_argument("-v", "--verbosity", type=int, help = "Increase verbosity", choices=[ofl.SILENT,ofl.ERROR,ofl.WARN,ofl.INFO,ofl.DEBUG],default=ofl.ERROR)

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

ofl.debug("path : % s" %path)
ofl.debug("base : % s" %base)

camera  = get_camera(args.camera,conf)
command = ofl.oscad + (camera if camera else [])

cmds = []
cases = []
if os.path.isfile(json):
  ofl.debug("JSON file found")
  cases = test_cases(ofl.read_lines(json))
  if cases:
    ofl.debug(str(len(cases))+" TEST CONFIG(s) found")
    for case in cases:
      cmds.append(command+['-P',case])
  else:
    ofl.debug("NO TEST CONFIG(s) found")
    cmds.append(command)
else:
  ofl.debug("JSON file not found")
  cmds.append(command)

for i, cmd in enumerate(cmds):
  if cases:
    case = cases[i]
    o_base = case
    o_dir = os.path.join(path,base+'.echo')
    if not os.path.exists(o_dir) and not args.dry_run:
      os.mkdir(o_dir)
  else:
    case =None
    o_base=base
    o_dir=path
  o_file = echo(o_dir,o_base)
  rc = run(base,cmd+[scad],o_file,args.dry_run,case)
  if rc!=0:
    cat(echo(o_dir,o_base))
    exit(rc)
