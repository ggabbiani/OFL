#!/usr/bin/env python3
# version 'bumper'
#
# This file is part of the 'OpenSCAD Foundation Library' (OFL) project.
#
# Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later
#

import argparse, os, re, subprocess, signal

from termcolor import colored, cprint
from typing import NamedTuple

import ofl

class Version:
    major: int
    minor: int
    patch: int

    def __init__(self,major=None,minor=None,patch=None):
        if major is None and minor is None and patch is None:
            try:
                tag = subprocess.check_output(['git', 'describe', '--abbrev=0'], stderr=subprocess.STDOUT, universal_newlines=True).strip("\n")[1:]
            except subprocess.CalledProcessError as exc_info:
                raise RuntimeError(str(exc_info.output))
            regex   = re.compile(r"^(?P<major>\d+)\.(?P<minor>\d+)\.(?P<patch>\d+)$")
            match   = regex.match(tag)
            if not match:
                raise RuntimeError(f"{version} does not match the expected version pattern.")
            self.major  = int(match.group("major"))
            self.minor  = int(match.group("minor"))
            self.patch  = int(match.group("patch"))
        else:
            self.major  = major
            self.minor  = minor
            self.patch  = patch

    def bump(self, mode):
        if mode == "major":
            return Version(self.major+1,0,0)
        elif mode == "minor":
            return Version(self.major,self.minor+1,0)
        elif mode == "patch":
            return Version(self.major,self.minor,self.patch+1)
        else:
            raise RuntimeError("Unexpected bump mode f{mode}")

    def __str__ (self):
        return str(self.major)+'.'+str(self.minor)+'.'+str(self.patch)

    def tag(self):
        return 'v'+str(self)


def handler(signum, frame):
    cprint('\n\n***INTERRUPTED***\n','red')
    exit(0)

def git_version_tag():
    try:
        git_tag = subprocess.check_output(['git', 'describe', '--abbrev=0'], stderr=subprocess.STDOUT, universal_newlines=True).strip("\n")[1:]
    except subprocess.CalledProcessError as exc_info:
        raise RuntimeError(str(exc_info.output))
    return git_tag

def git_branch():
    try:
        branch = subprocess.check_output(['git', 'rev-parse', '--abbrev-ref', 'HEAD'], stderr=subprocess.STDOUT, universal_newlines=True).strip("\n")
    except subprocess.CalledProcessError as exc_info:
        raise RuntimeError(str(exc_info.output))
    return branch

def git_chk():
    out = subprocess.run(['git', 'status', '--porcelain'], check=True, capture_output=True, text=True).stdout
    if out.count('\n')>0:
        raise RuntimeError(f'Unclear git status:\n\n{out}')

def parse_args():
    parser = argparse.ArgumentParser(description='Bump version on remote git origin.')
    parser.add_argument("-v", "--verbosity", type=int, help = f"increase verbosity (default {ofl.verbosity})", choices=[ofl.SILENT,ofl.ERROR,ofl.WARN,ofl.INFO,ofl.DEBUG],default=ofl.ERROR)
    parser.add_argument('-d', '--dry-run',action='store_true', help='no concrete modification performed on GIT repo. (default false)', default=False)
    m_excl = parser.add_mutually_exclusive_group()
    m_excl.add_argument('-M', '--major',  action='store_true', help='auto increment current major release number')
    m_excl.add_argument('-m', '--minor',  action='store_true', help='auto increment current minor release number')
    m_excl.add_argument('-p', '--patch',  action='store_true', help='auto increment current patch release number (default)', default=True)
    args = parser.parse_args()
    ofl.verbosity   = args.verbosity
    return args

def lib_update(version: Version):
    backup_file = str(core_file)+'.bak'
    with open(backup_file,"w+") as output:
        output.writelines(ofl.read_lines(core_file))
    match = False
    with open(backup_file) as input, open(core_file,"w+") as output:
        for line in input:
            if not match:
                new = re.sub(r"^function\s+fl_version\(\)\s*\=\s*\[(\d+,\d+,\d)\]\s*;\s*$",
                             f"function fl_version() = [{version.major},{version.minor},{version.patch}];\n",
                             line)
                if new!=line:
                    match = True
                    line = new
            output.writelines(line)
    return match

# def cat(version):
#     '''
#     emulates POSIX 'cat' command
#     '''
#     lines = re.sub(r"^function\s*fl_version\(\)\s*\=\s*\[(\d+,\d+,\d)\]\s*;$"m,f"function fl_version() = [{version.major},{version.minor},{version.patch}];",ofl.read_lines(output))
#     print(lines)


signal.signal(signal.SIGINT, handler)

CLI = parse_args()

try:
    version = Version()
    if CLI.major:
        mode = "major"
    elif CLI.minor:
        mode = "minor"
    else:
        mode = "patch"
    bumped  = version.bump(mode)
    branch  = git_branch()
    core_file = ofl.lib.joinpath('OFL/foundation/core.scad')

    ofl.info(f"Mode                 : {mode}")
    ofl.info(f"Current version      : {version}")
    ofl.info(f"New (bumped) version : {bumped}")
    ofl.info(f"Current branch       : '{branch}'")
    ofl.info(f"OFL path             : {ofl.path}")
    ofl.info(f"OFL library          : {ofl.lib}")
    git_chk()

    print(
    f'''
    this script is going to:

    * update and commit:
        - {core_file} ({bumped.major}.{bumped.minor}.{bumped.patch});
        - Documentation
    * annotate local repo as {bumped.tag()};
    * push updates and {bumped.tag()} annotation to remote repo
    '''
    )

    if ofl.confirm("press 'y' to continue or 'n' to exit"):
        cmd_doc     = ['make', '-s', 'docs/all']
        cmd_commit  = ['git', 'commit', '-m', f'Version {str(bumped)} bumped', '-a']
        cmd_tag     = ['git', 'tag', '-m', f'Version {str(bumped)} bumped', bumped.tag(), branch]
        cmd_push    = ['git', 'push', '--follow-tags']
        if CLI.dry_run:
            print(cmd_doc)
            print(cmd_commit)
            print(cmd_tag)
            print(cmd_push)
        else:
            subprocess.run(['/bin/false'], check=True)
#        lib_update(bumped)
#        subprocess.run(cmd_doc, check=True)
#        subprocess.run(cmd_tag, check=True)
#        subprocess.run(cmd_push, check=True)

except RuntimeError as error:
    ofl.error('***ERROR***:')
    print(error)