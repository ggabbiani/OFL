#!/bin/bash
###############################################################################
# Outputs GraphViz dot file for dependencies tree upon foundation or vitamins
#
# <OFL> repo root is auto-retrieved from this script real path.
#
set -e # exit immediately in case of error
OFL="$(realpath $(dirname $0)/..)"
. $OFL/bin/functions.sh
trap 'on_exit $? $test' EXIT

help() {
cat <<EoH

$(basename $0) [-?|-h|--help] [-f|--foundation] [-v|--vitamins]

  -?|-h|--help      this help
  -f|--foundation   foundation dependencies scan
  -s|--silent       less verbose
  -v|--vitamins     vitamins dependencies scan

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

locals() {
  grep -e '^use[[:space:]]*<' -e '^include[[:space:]]*<' $OFL/$MODE/*.scad | sed -e 's@^.*/OFL/[[:alnum:]]*/@@g' -e 's/[[:space:]]*</:/g' -e 's/>.*$//g' | grep -v -e ':\.\./' -v -e scad-utils -v -e TOUL -v -e NopSCADlib | sed -e 's/\.scad//g'
}

modules() {
  cd $OFL/$MODE && ls -Q -l *.scad | sed -e 's/.* //g' -e 's/\.scad//g' && cd - >/dev/null
}

digraph() {
cat <<EOF
digraph "$MODE" {

  bgcolor = white

  node [
    fillcolor = white,style = "filled",
    width = "1.38889",height = "0.416667",
    shape = rect,
    color = black,
    penwidth = 2
  ];

$modules

  edge [
    weight = 1,
    penwidth = 1,
    label = "«include»",
    color = black,
    style = solid
  ];

$includes

  edge [
    weight = 1,
    penwidth = 2,
    xlabel = "«use»",
    color = red,
    style = solid
  ];

$uses

}
EOF
}

VERBOSE="1"
MODE="foundation"

##############################################################################
# parsing
POSITIONALS=""
while (( "$#" )); do
  case "$1" in
    '-?'|-h|--help)
      help
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

# locals


modules=$(modules)
includes=$(locals | grep_no_rc -e '\:include\:' | sed -e 's/^/"/' -e 's/\:include\:/" -> "/g' -e 's/$/"/')
uses=$(locals | grep_no_rc -e '\:use\:'  | sed -e 's/^/"/' -e 's/\:use\:/" -> "/g' -e 's/$/"/')

info "modules: $modules"
info "includes: $includes"
info "uses: $uses"

digraph >"$OFL/$MODE/docs/dependencies.dot"
# digraph
