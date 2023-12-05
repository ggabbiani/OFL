#!/usr/bin/env python3
# version 'bumper'
#
# This file is part of the 'OpenSCAD Foundation Library' (OFL) project.
#
# Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later
#

import argparse
import re
import subprocess
import signal

from termcolor import colored, cprint

import ofl

def handler(signum, frame):
    cprint('\n\n***INTERRUPTED***\n','red')
    exit(0)

def git_version_tag():
    try:
        git_tag = str(
            subprocess.check_output(['git', 'describe', '--abbrev=0'], stderr=subprocess.STDOUT)
        ).strip('\'b\\n')[1:]
    except subprocess.CalledProcessError as exc_info:
        raise RuntimeError(str(exc_info.output))
    return git_tag

def git_branch():
    try:
        branch = str(
            subprocess.check_output(['git', 'rev-parse', '--abbrev-ref', 'HEAD'], stderr=subprocess.STDOUT)
        ).strip('\'b\\n')
    except subprocess.CalledProcessError as exc_info:
        raise RuntimeError(str(exc_info.output))
    return branch

def bump_version(version, mode):
    mo = VERSION_RE.match(version)
    if not mo:
        raise RuntimeError(f"{version} does not match the expected version pattern.")
    major = mo.group("major")
    minor = mo.group("minor")
    patch = mo.group("patch")
    if mode == "major":
        major = int(major) + 1
        minor = 0
        patch = 0
    elif mode == "minor":
        minor = int(minor) + 1
        patch = 0
    elif mode == "patch":
        patch = int(patch) + 1
    else:
        raise RuntimeError("Unexpected bumpversion mode f{mode}")
    return f"{major}.{minor}.{patch}"

def git_chk():
    out = subprocess.run(['git', 'status', '--porcelain'], check=True, capture_output=True, text=True).stdout
    if out.count('\n')>0:
        raise RuntimeError(f'Unclear git status:\n\n{out}')

signal.signal(signal.SIGINT, handler)

parser = argparse.ArgumentParser(description='Bump version on remote git origin.')
parser.add_argument("-v", "--verbosity", type=int, help = "Increase verbosity", choices=[ofl.SILENT,ofl.ERROR,ofl.WARN,ofl.INFO,ofl.DEBUG],default=ofl.ERROR)
parser.add_argument('-d', '--dry-run',action='store_true', help='no concrete modification performed on GIT repo. (default false)', default=False)
parser.add_argument('-M', '--major',  action='store_true', help='auto increment current major release number')
parser.add_argument('-m', '--minor',  action='store_true', help='auto increment current minor release number')
parser.add_argument('-p', '--patch',  action='store_true', help='auto increment current patch release number (default)', default=True)
args = parser.parse_args()

try:
    if args.major:
        mode = "major"
    elif args.minor:
        mode = "minor"
    else:
        mode = "patch"

    VERSION_RE      = re.compile(r"^(?P<major>\d+)\.(?P<minor>\d+)\.(?P<patch>\d+)$")
    PROJECT_VERSION = git_version_tag()
    BUMPED_VERSION  = bump_version(PROJECT_VERSION, mode)
    PROJECT_BRANCH  = git_branch()
    TAG             = 'v{0}'.format(BUMPED_VERSION)
    git_chk()

    ofl.info(f"Mode                 : {mode}")
    ofl.info(f"Current version      : {PROJECT_VERSION}")
    ofl.info(f"New (bumped) version : {BUMPED_VERSION}")
    ofl.info(f"Current branch       : {PROJECT_BRANCH}")

    print(
    '''
    this script is going to:

    * annotate local repo as {0};
    * push updates and {0} annotation to remote repo
    '''
    .format(TAG)
    )

    if ofl.confirm('press «RETURN» to continue or «CTRL-C» to exit'):
        cmd_tag     = ['git', 'tag', '-m', f'Version {BUMPED_VERSION} bumped', TAG, PROJECT_BRANCH]
        cmd_push    = ['git', 'push', '--follow-tags']
        if args.dry_run:
            print(cmd_tag)
            print(cmd_push)
        else:
            subprocess.run(['/bin/false'], check=True)
#        subprocess.run(cmd_tag, check=True)
#        subprocess.run(cmd_push, check=True)

except RuntimeError as error:
    print(error)