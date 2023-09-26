#!/usr/bin/env python3
#
# Creates new test.conf from a skeleton
#
# This file is part of the 'OpenSCAD Foundation Library' (OFL) project.
#
# Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later
#

import argparse
import os
import sys

from shutil import copyfile
from termcolor import colored, cprint

script_directory  = os.path.dirname(os.path.abspath(sys.argv[0]))
ofl_directory     = os.path.abspath(os.path.join(script_directory, os.pardir))
test_directory    = os.path.abspath(os.path.join(ofl_directory, "tests"))

parser = argparse.ArgumentParser()
parser.add_argument("test", type=str, help="test name")
parser.add_argument("-t", "--template", help = "test template type", choices=['nogui', '2d', '3d'], default='3d')
parser.add_argument("-v", "--verbosity", type=int, help = "command verbosity", choices=[0,1,2],default=0)

def info(message):
  if args.verbosity>1:
    return cprint("[*INF*] "+message, 'green')

def warn(message):
  if args.verbosity>0:
    return cprint("[*WRN*] "+message, 'yellow')

def confirm(message):
  print((colored(message+" ", 'yellow')),end="",flush=True)
  ch  = None
  yes = None
  no  = None
  while True:
    ch, yes, no = sys.stdin.read(1).lower(), ch=="y", ch=="n"
    if yes or no:
      break
  return False if no else True

def error(message):
  if args.verbosity>0:
    return cprint("[*ERR*] "+message, 'red')

def debug(message):
  return cprint("[*ERR*] "+message, 'red')

# Read arguments from command line
args = parser.parse_args()

target_dir  = os.path.dirname(os.path.join(test_directory,args.test))
test_name   = os.path.basename(os.path.abspath(args.test))+"-test"

source = os.path.join(test_directory,"skeleton-"+args.template+".conf")
target   = os.path.join(target_dir,test_name+".conf")

info("Test    : % s" % args.test)
info("Template: % s" % args.template)
info("OFL     : %s" % ofl_directory)
info("tests   : %s" % test_directory)

info("source skeleton: %s" % source)
info("target config: %s" % target)

if os.path.exists(target) and not confirm(f"OVERWRITE '{target}'?"):
  warn("Test creation interrupted")
  sys.exit(1)

copyfile(source,target)
info(f"{target} created.")
sys.exit()
