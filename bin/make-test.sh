#!/bin/bash
#
# test execution helper for makefile usage
# this file is now OBSOLETE: use make-test.py in place of this
#
# This file is part of the 'OpenSCAD Foundation Library' (OFL) project.
#
# Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later
#

set -e # exit immediately in case of error
OFL="$(realpath $(dirname $0)/..)"
. $OFL/bin/functions.sh
trap 'on_exit $? $NAME' EXIT

help() {
cat <<EoH

$(basename $0) [-?|-h|--help] [-d|--dry-run] [TEST]

  TEST          abstract name of the test-case

  -?|-h|--help  this help
  -c|--camera   OpenSCAD camera position
  -d|--dry-run  on screen dump only of the generated dot file (default OFF)
  -s|--silent   silent run

EoH
exit 0
}

grep_no_rc() {
  grep $@ || true
}

on_exit() {
  if [ "$1" != "0" ]; then
    color_message ${COLOR_RED} "$2 failed ($1)."
  else
    rm -f $ECHO
  fi
}

VERBOSE="1"
MODE="foundation"
DRY="OFF"
# until [issue #3616](https://github.com/openscad/openscad/issues/3616) is not
# applied to stable OpenSCAD branch we have to use a nightly build or check the
# command output
OSCAD="$(which openscad) --hardwarnings"
# OSCAD="/home/giampa/projects/openscad/build/openscad --hardwarnings"
# OSCAD="/home/giampa/projects/openscad/build/openscad"
TEMP_ROOT="/tmp"

##############################################################################
# parsing
POSITIONALS=""
while (( "$#" )); do
  case "$1" in
    '-?'|-h|--help)
      help
      shift
      ;;
    -d|--dry-run)
      DRY="ON"
      shift
      ;;
    -c|--camera)
      CAMERA="$2"
      shift 2
      ;;
    -s|--silent)
      VERBOSE="0"
      shift
      ;;
    --) # end argument parsing
      shift
      EXTRAS="$@"
      break
      ;;
    -*|--*=) # unsupported flags
      fail 1 "Unsupported flag $1"
      ;;
    *) # preserve positional arguments
      POSITIONALS="$POSITIONALS $1"
      shift
      ;;
  esac
done
# set positional arguments in their proper place
eval set -- "$POSITIONALS"

if [ "$#" -lt "1" ]; then
  fail "test name expected"
fi
NAME="$1"
CONF="$NAME.conf"
JSON="$NAME.json"
SCAD="$NAME.scad"
if [ -n "$CAMERA" ]; then
  OSCAD="$OSCAD --camera $CAMERA"
fi
ECHO=$NAME.echo

if [ -f "$JSON" ]; then
  match=$(grep -e "TEST_CASE-" "$JSON" || true)
  if [ -n "$match" ]; then # execution of all the tests eventually present in the json file
    info "TESTCONFIG(s) found in $JSON file"

    source $(realpath $CONF)
    grep -e "TEST_CASE-" "$JSON" | sed -e 's/\:.*//g' -e 's/^ *//g' | xargs -I {} sh -c "$OSCAD -P {} -o $TEMP_ROOT/$NAME-{}.echo $SCAD && echo -e \"\e[33m$NAME ({}):\e[0m \e[32mexecuted\e[0m\""

    cat $TEMP_ROOT/$NAME-TEST_CASE-*.echo >$ECHO
    rm $TEMP_ROOT/$NAME-TEST_CASE-*.echo
  else # execution of the scad test with default config
    info "no TEST_CASE found in $JSON"
    source $(realpath $CONF) \
    && sh -c "$OSCAD -o $ECHO $SCAD && echo -e \"\e[33m$NAME:\e[0m \e[32mexecuted\e[0m\""
  fi
else   # execution of the scad test with default config
  info "$JSON file not found"
  source $(realpath $CONF) \
  && sh -c "$OSCAD -o $ECHO $SCAD && echo -e \"\e[33m$NAME:\e[0m \e[32mexecuted\e[0m\""
fi

exit 0
