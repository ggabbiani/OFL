#!/bin/bash
###############################################################################
# 
#
# 
#
set -e # exit immediately in case of error
OFL="$(realpath $(dirname $0)/..)"
. $OFL/bin/functions.sh
trap 'on_exit $? $test' EXIT

help() {
cat <<EoH

$(basename $0) [-?|-h|--help] [-d|--dry-run] [-f|--foundation] [-v|--vitamins] [-s|--silent]

  -?|-h|--help      this help
  -d|--dry-run      on screen dump only of the generated dot file (default OFF)
  -f|--foundation   foundation dependencies scan (default ON)
  -s|--silent       less verbose (default OFF)
  -v|--vitamins     vitamins dependencies scan (default OFF)

EoH
exit 0
}

grep_no_rc() {
  grep $@ || true
}

on_exit() {
  if [ "$1" != "0" ]; then
    color_message ${COLOR_RED} "$2 failed."
  fi
}

VERBOSE="1"
MODE="foundation"
DRY="OFF"

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
    -f|--foundation)
      MODE="foundation"
      shift
      ;;
    -s|--silent)
      VERBOSE="0"
      shift
      ;;
    -v|--vitamins)
      MODE="vitamins"
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

info "Mode $MODE"

cd $OFL
[[ -e "$MODE/docs/pic-index.md" ]] && \
grep -e '| ' "$MODE/docs/pic-index.md" \
  | tail -n +3 \
  | awk -v MODE="$MODE" '{print "-p tests/"$10"/"$4".json -o " MODE"/docs/"$2".png --P "$2" --imgsize "$6" --view "$8" --viewall tests/"$10"/"$4".scad";}' \
  | xargs -L1 /usr/bin/openscad

exit 0