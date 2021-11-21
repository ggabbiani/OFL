#!/bin/bash

help() {
cat <<EoH
OpenSCAD Foundation Library test suite

$(basename $0) [-d|--debug] [-?|-h|--help] [--import <import directory>] [-i|--interactive] [--export <export directory>]

  -d,--debug        turns on debug messages
  -?,-h,--help      this text
  -i,--interactive  executes a bash and exits
  --import <DIR>    OFL directory (default /import)
  --export <DIR>    working directory (default /export)
  -v|--verbose      verbose output when set, silent otherwise (default silent)

EoH
}

info() {
  echo -e "---- info [$(basename $0)] ----\n$*\n"
}

warn() {
  echo -e "**** WARN [$(basename $0)] ****\n$*\n"
}

fail() {
  re='^[0-9]+$'
  if [[ $1 =~ $re ]] ; then
    RC="$1"
    shift
  else
    RC=1
  fi
  MSG="$1"
  echo -e "**** FAIL [$(basename $0)] ****\n$MSG\n">&2
  exit $RC
}

info "$@"

IMPORT="/import"
EXPORT="/export"
VERBOSE="0"
INTERACTIVE="0"

##############################################################################
# parsing
POSITIONALS=""
while (( "$#" )); do
  case "$1" in
    -d|--debug)
      set -x
      shift
      ;;
    '-?'|-h|--help)
      help
      exit 1
      ;;
    --import)
      IMPORT=$(realpath "$2")
      shift 2
      ;;
    --export)
      EXPORT=$(realpath "$2")
      shift 2
      ;;
    -i|--interactive)
      shift
      /bin/bash
      exit 0
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

cat <<EoM
-------------------------------------
+EXPORT : $EXPORT
+IMPORT : $IMPORT

EoM

$IMPORT/bin/test.sh -v
