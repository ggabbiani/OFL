#!/bin/bash
###############################################################################
# Executes all the OpenSCAD scripts present in the <OFL>/tests directory.
#
# An OpenSCAD script is recognized as 'test' when all the conditions are met:
# * script is inside <OFL>/tests directory
# * script file name is in the form <name>"-test.scad"
#
# <OFL> repo root is auto-retrieved from this script real path.
#
# Test results are session persistent since written inside 
# /var/tmp/<random directory name>/
# 
OFL="$(dirname $(realpath $0))/.."
. $OFL/bin/functions.sh

help() {
cat <<EoH

$(basename $0) [-?|-h|--help] [-i|--interactive] [-v|--verbose] 

  -?|-h|--help      this help
  -i|--interactive  when unset confirmations are inibhited (default unset)
  -v|--verbose      verbose output when set, silent otherwise (default silent)
  
EoH
exit 0
}

on_exit() {
  if [ "$1" != "0" ]; then
    echo -e "${COLOR_RED}[*ERR*] $2 failed.${COLOR_DEFAULT}"
  fi
}

catch() {
  echo $*
  echo "***FAILED*** $2"
  exit $1
}

set -e  # exit immediately in case of error
trap 'on_exit $? $test' EXIT
# trap 'catch $? $test' ERR

OUT=$(mktemp -d -p /var/tmp SCAD_TEST_XXXXXXXX)
CMD="openscad"
VERBOSE="0"
INTERACTIVE="0"

##############################################################################
# parsing
POSITIONALS=""
while (( "$#" )); do
  case "$1" in
    '-?'|-h|--help)
      help
      shift
      ;;
    -i|--interactive)
      INTERACTIVE="1"
      shift
      ;;
    -v|--verbose)
      VERBOSE="1"
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

info "Output directory set to: '$OUT'."
for test in $(find $OFL/tests/ -name '*-test.scad'); do
  info "running `basename $test .scad`"
  "$CMD" -o $OUT/`basename $test .scad`.echo $test
done

if [ "$INTERACTIVE" -eq "1" ]; then
  read -p "Press <ENTER> for deleting workdir $OUT"
fi
rm -r "$OUT"
