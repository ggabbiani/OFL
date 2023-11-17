#!/bin/bash
###############################################################################
# Executes all the OpenSCAD scripts present in the <OFL>/src/tests directory.
#
# An OpenSCAD script is recognized as 'test' when following conditions are met:
#
# * script is inside <OFL>/tests directory
# * script file name is in the form <name>"-test.scad"
#
# <OFL> repo root is auto-retrieved from this script real path.
#
# Test results are session persistent since written inside
# /var/tmp/<random directory name>/
#
set -e # exit immediately in case of error
OFL="$(realpath $(dirname $0)/..)"
TESTS="$OFL/tests"
. $OFL/bin/functions.sh
trap 'on_exit $? $test $OFILE' EXIT
# trap 'catch $? $test' ERR

help() {
cat <<EoH

$(basename $0) [-?|-h|--help] [-i|--interactive] [-s|--silent]

  -?|-h|--help      this help
  -i|--interactive  when unset confirmations are inhibited (default unset)
  -s|--silent       silent output when set, verbose otherwise (default verbose)

EoH
exit 0
}

on_exit() {
  if [ "$1" != "0" ]; then
    color_message ${COLOR_RED} "$2 failed."
    if [ "$3" != "" ]; then
      cat "$3"
    fi
  fi
}

catch() {
  echo $*
  echo "***FAILED*** $2"
  exit $1
}

OUT=$(mktemp -d -p /var/tmp OFL_TESTS_XXXXXXXX)
CMD="$(which openscad)"
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
for test in $(find $TESTS/ -name '*-test.scad'); do
  info "running `basename $test .scad`"
  OFILE="$OUT/$(basename $test .scad).echo"
  # "$CMD" "--hardwarnings" -o $OFILE $test
  "$CMD" -o $OFILE $test
  ERROR=$(grep -e "WARNING:" -e "ERROR:" $OFILE | grep -v 'WARNING: Viewall and autocenter disabled in favor of $vp*' |wc -l)
  if [ "$ERROR" -ne "0" ]; then
    # echo $ERROR
    # cat $OFILE
    exit 1
  fi
done

if [ "$INTERACTIVE" -eq "1" ]; then
  read -p "Press <ENTER> for deleting workdir $OUT"
fi
rm -r "$OUT"
