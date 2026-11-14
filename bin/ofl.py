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

import argparse, os, platform, re, subprocess, sys

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

def rc_epilogue(rc):
  if rc==0:
    cprint('✔','green')
  else:
    cprint(f'✝ ({rc})','red')
  return rc

def conf_values(fname):
  '''
  returns the variables defined by a test .conf file as a dictionary.

  The file is sourced by bash exactly like the test makefiles do, so the full
  shell syntax (heredocs, variable expansion...) is supported. Only the
  variables set or changed by the file are returned.
  '''
  out = subprocess.run(
    ['bash', '-c', 'env -0 && printf "\\0@@CONF@@\\0" && set -a && . "$1" && env -0', '_', fname],
    capture_output=True, check=True
  ).stdout.decode()
  before, after = out.split('\0@@CONF@@\0')
  parse = lambda env: dict(kv.split('=', 1) for kv in env.split('\0') if '=' in kv)
  before, after = parse(before), parse(after)
  return {k: v for k, v in after.items() if before.get(k) != v and k not in ('_', 'SHLVL')}

def read_lines(fname):
  '''
  returns all «fname» lines
  '''
  with open(fname) as file:
    return file.readlines()

def openscad(scad_f, parms=[], echo_f=None, hw=False, dry_run=False, must_fail=False):
  scad_f  = os.path.normpath(scad_f)
  if echo_f is None:
    echo_f  = os.path.join(os.path.dirname(scad_f),os.path.splitext(os.path.basename(scad_f))[0]+'.echo')
  debug("echo_f: % s" %echo_f)
  cmd = [oscad_cmd] + parms
  # NOTE: we cannot use the --hardwarnings parameter because of the useless
  # 'Viewall and autocenter' warn
  if hw:
    cmd += ["-o",echo_f]
  cmd += [scad_f]
  if dry_run:
    print(cmd)
  else:
    result = subprocess.run(cmd,capture_output=True,text=True,check=not must_fail)
    debug("result: % s" %result)
    if hw:
      lines = read_lines(echo_f)
      for line in lines:
        # negative lookahead for excluding the useless 'Viewall and autocenter' warn
        match   = re.findall(r"^(WARNING|ERROR): (?!Viewall and autocenter disabled in favor of \$vp\*)",line)
        if match:
          result.returncode = 1
    return result

SILENT  = 0
ERROR   = 1
WARN    = 2
INFO    = 3
DEBUG   = 4

oscad_cmd = "openscad" if platform.system()=='Linux' else "/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD" if platform.system()=='Darwin' else 'Badula'

verbosity = ERROR
oscad     = [
  oscad_cmd,
  "--hardwarnings"
]
path      = Path(__file__).parent.parent.absolute()
lib       = path.joinpath('lib')

# if __name__ == "__main__":
#     import sys
#     blah blah ...