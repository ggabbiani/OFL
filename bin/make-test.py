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

def arguments(conf_file):
  result      = []
  dictionary  = dotenv.dotenv_values(conf_file) if os.path.isfile(conf_file) else []
  camera      = args.camera      if args.camera     else dictionary.get('ARG_CAMERA')
  projection  = args.projection  if args.projection else dictionary.get('ARG_PROJECTION')
  if camera:
    result = result + ['--camera', camera]
  if projection:
    result = result + ['--projection', projection]
  return result

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

def prologue(title,case=None):
  if (case):
    print((colored(title+f" [{case}]: ", 'yellow')),end="",flush=True)
  else:
    print((colored(title+": ", 'yellow')),end="",flush=True)

def run(title,test,parms,output,dry_run=False,case=None):
  if not dry_run:
    prologue(title,case=case)
  rc = ofl.openscad(test,parms=parms,echo_f=output,hw=True,dry_run=dry_run)
  return ofl.rc_epilogue(rc) if not dry_run else rc

def echo(path,base):
  return os.path.join(path,base+'.echo')

parser = argparse.ArgumentParser()
parser.add_argument(      "--must-fail", action='store_true', help = "asserts command failure")
parser.add_argument("-c", "--camera", help = "OpenSCAD camera position")
parser.add_argument("-d", "--dry-run", action='store_true', help = "On screen dump only of the generated dot file")
parser.add_argument("-p", "--projection", help = "(o)rtho or (p)erspective when exporting png")
parser.add_argument("-t", "--temp-root", type=str, help = "Temporary directory path", choices=["/var/tmp","/tmp"],default="/tmp")
parser.add_argument("-v", "--verbosity", type=int, help = "Increase verbosity", choices=[ofl.SILENT,ofl.ERROR,ofl.WARN,ofl.INFO,ofl.DEBUG],default=ofl.ERROR)

parser.add_argument("test", type=str, help="Full test path WITHOUT SUFFIX")

args = parser.parse_args()

ofl.verbosity   = args.verbosity

ofl.info("Camera        : % s" %args.camera)
ofl.info("Projection    : % s" %args.projection)
ofl.info("Dry run       : % s" %args.dry_run)
ofl.info("OSCAD         : % s" %ofl.oscad)
ofl.info("Verbosity     : % s" %args.verbosity)
ofl.info("Failure       : % s" %args.must_fail)

full    = os.path.normpath(args.test)
path    = os.path.dirname(full)
base    = os.path.basename(full)
conf    = os.path.join(path,base+'.conf')
json    = os.path.join(path,base+'.json')
scad    = os.path.join(path,base+'.scad')

ofl.debug("path : % s" %path)
ofl.debug("base : % s" %base)

command = arguments(conf)
cmds    = []
cases   = []

if os.path.isfile(json):
  ofl.debug("JSON file found")
  cases = test_cases(ofl.read_lines(json))
  if cases:
    ofl.debug(str(len(cases))+" TEST CONFIG(s) found")
    for case in cases:
      cmds.append(command+['-p',json]+['-P',case])
  else:
    ofl.debug("NO TEST CONFIG(s) found")
    cmds.append(command)
else:
  ofl.debug("JSON file not found")
  cmds.append(command)

for i, cmd in enumerate(cmds):
  if cases:
    case = cases[i][10:]
    o_base = case
    o_dir = os.path.join(path,base+'.echo')
    if not os.path.exists(o_dir) and not args.dry_run:
      os.mkdir(o_dir)
  else:
    case    = None
    o_base  = base
    o_dir   = path

  o_file  = echo(o_dir,o_base)
  result  = ofl.openscad(scad,parms=cmd,echo_f=o_file,hw=True,dry_run=args.dry_run,must_fail=args.must_fail)
  if result.returncode==0:
    cprint(f'{case if case else "✔"}', 'green',end=" ")
  else:
    cprint(f'{case if case else "✝"}', 'red',  end=" ")

  if not args.must_fail and result.returncode!=0:
    print("\n")
    cprint(f'{result}', 'red')
    cat(echo(o_dir,o_base))
    exit(1)