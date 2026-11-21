#!/usr/bin/env python3
#
# Creates a new «name»-test.conf from a skeleton and generates the
# corresponding (working) «name»-test.scad
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
import subprocess
import sys

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

if not os.path.isfile(os.path.join(target_dir,"Makefile")):
  cprint(f"[*ERR*] '{target_dir}' is not a test directory (no Makefile found)",'red')
  sys.exit(1)

# skeleton copy, with the OFL library path relative to the test directory:
# every value not set by the new configuration is inherited from
# tests/defaults.conf when the test source is generated
lib_path  = os.path.relpath(os.path.join(ofl_directory,"lib","OFL"),target_dir)
with open(source) as f:
  conf = f.read().replace("@LIB@",lib_path)
with open(target,"w") as f:
  f.write(conf)
info(f"{target} created.")

# immediate generation of the test source, so to start from a working test
rel_name  = os.path.relpath(os.path.join(target_dir,test_name),ofl_directory)
scad      = rel_name+".scad"
result    = subprocess.run(["make","-s",scad],cwd=ofl_directory)
if result.returncode!=0:
  cprint(f"[*ERR*] '{scad}' generation failed",'red')
  sys.exit(1)

# T_LIST membership check
short_name = test_name[:-len("-test")]
with open(os.path.join(target_dir,"Makefile")) as f:
  makefile = f.read().replace("\\\n"," ")
t_list = next((line.split("=",1)[1].split() for line in makefile.splitlines() if re.match(r"^T_LIST\s*=",line)),[])
rel_dir = os.path.relpath(target_dir,ofl_directory)

cprint(f"\nTest '{rel_name}' created from the '{args.template}' skeleton.",'green')
print(f"""
Next steps:
  1. open {scad} in OpenSCAD with 'Design → Automatic Reload and Preview'
  2. edit {rel_name}.conf (NEVER the .scad), then regenerate with:
       make -s {scad}
     values not set in the .conf are inherited from tests/defaults.conf,
     to see the effective ones:
       make -s {rel_name}.vars
  3. optionally save Customizer presets in {rel_name}.json:
       TEST_CASE*  are run as test cases
       fig_*       can be reused by the documentation pictures""")
if short_name in t_list:
  print(f"  4. '{short_name}' is already in the T_LIST of {rel_dir}/Makefile")
else:
  cprint(f"  4. add '{short_name}' to the T_LIST of {rel_dir}/Makefile",'yellow')
print(f"  5. run it with: make -s {rel_name}.echo  (or the whole suite: make -s tests/runs)")
sys.exit()
