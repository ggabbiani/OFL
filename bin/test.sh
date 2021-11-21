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

$(basename $0) [-?|-h|--help] [-i|--interactive] [-s|--silent] 

  -?|-h|--help      this help
  -i|--interactive  when unset confirmations are inibhited (default unset)
  -s|--silent       silent output when set, verbose otherwise (default verbose)
  
EoH
exit 0
}

on_exit() {
  if [ "$1" != "0" ]; then
    color_message ${COLOR_RED} "$2 failed."
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
VERBOSE="1"
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

info "Output directory set to: '$OUT'."
for test in $(find $OFL/tests/ -name '*-test.scad'); do
  info "running `basename $test .scad`"
  OFILE="$OUT/$(basename $test .scad).echo"
  "$CMD" --hardwarnings -o $OFILE $test
  # --hardwarnings doesn't change openscad return code even when terminated by warn
  # so a further check must be done in order to be sure that no warning are present 
  ERROR=$(grep "WARNING:" $OFILE|wc -l)
  if [ "$ERROR" -ne "0" ]; then 
    cat $OFILE
    fail 1 "Error on $(basename $test)"
  fi
done

if [ "$INTERACTIVE" -eq "1" ]; then
  read -p "Press <ENTER> for deleting workdir $OUT"
fi
rm -r "$OUT"
