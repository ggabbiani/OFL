#!/usr/bin/env python3
#
# some useful functions (mainly formatted output related)
#
# This file is part of the 'OpenSCAD Foundation Library' (OFL) project.
#
# Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later
#

import argparse, os, sys

from pathlib import Path
from termcolor import colored, cprint

def debug(message):
  if verbosity>=DEBUG:
    return cprint("[*DBG*] "+message, 'magenta')

def info(message):
  if verbosity>=INFO:
    return cprint("[*INF*] "+message, 'green')

def warn(message):
  if verbosity>=WARN:
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
  if verbosity>=ERROR:
    return cprint("[*ERR*] "+message, 'red')

def read_lines(fname):
  '''
  returns all «fname» lines
  '''
  with open(fname) as file:
    return file.readlines()

SILENT  = 0
ERROR   = 1
WARN    = 2
INFO    = 3
DEBUG   = 4

verbosity = ERROR
oscad     = ["openscad", "--hardwarnings"]
# path      = os.path.realpath(__file__).dirname()
path      = Path(__file__).parent.parent.absolute()
lib       = path.joinpath('lib')

# if __name__ == "__main__":
#     import sys
#     blah blah ...