#/bin/bash.sh
# TODO: add documents update before release bump

set -e # exit immediately in case of error
OFL="$(realpath $(dirname $0)/..)"
. $OFL/bin/functions.sh
trap 'on_exit $? "$ERROR_MSG"' EXIT

on_exit() {
  if [ "$1" != "0" ]; then
    color_message ${COLOR_RED} "$2"
  fi
}

help() {
cat <<EOF
Usage: $(basename $0) [-d|--dry-run] [-M|--major] [-m|--minor] [-p|--patch] VERSION
Bump version on remote git origin.

Common flags
  -v, --verbose     guess what ...
  -d, --dry-run     no concrete modification performed on GIT repo. (default false)

Mutually exclusive optional arguments about VERSION auto increment.
  -M, --major       auto increment current major release number
  -m, --minor       auto increment current minor release number
  -p, --patch       auto increment current patch release number

The VERSION argument is formatted  according to Semantic Versioning v2.0.0.
Given a version number MAJOR.MINOR.PATCH, increment the:

  MAJOR version when you make incompatible API changes,
  MINOR version when you add functionality in a backwards compatible manner, and
  PATCH version when you make backwards compatible bug fixes.

NOTE: this command requires a 'clean' local git status (no modification uncommitted)
EOF
}

git_version() {
  git describe --abbrev=0|sed 's\^v\\g'
}

git_chk() {
  ERROR_MSG="Bad Git status"
  git status --porcelain|wc -l|grep '0' && info "Git status is clean"
}

REMOTE="NO"
DEFS="$OFL/foundation/defs.scad"
##############################################################################
# parsing
MAX=1
POSITIONALS=""
VERBOSE="0"
DRYRUN="0"
while (( "$#" )); do
  case "$1" in
    '-?'|-h|--help)
      shift
      help
      exit 0
      ;;
    -d|--dry-run)
      shift
      DRYRUN="1"
      ;;
    -M|--major)
      shift
      if [[ "$MAX" == "0" ]]; then
        fail 1 "Only one switch is possible"
      fi
      MAX=0
      INCREMENT="MAJOR"
      I=0
      ;;
    -m|--minor)
      shift
      if [[ "$MAX" == "0" ]]; then
        fail 1 "Only one switch is possible"
      fi
      MAX=0
      INCREMENT="MINOR"
      I=1
      ;;
    -p|--patch)
      shift
      if [[ "$MAX" == "0" ]]; then
        fail 1 "Only one switch is possible"
      fi
      MAX=0
      INCREMENT="PATCH"
      I=2
      ;;
    -v|--verbose)
      shift
      VERBOSE="1"
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

if [[ "$#" -gt "$MAX" ]]; then
  fail 1 "Too many arguments passed"
fi

if [[ "$INCREMENT" != "" ]]; then
  info "Auto increment of current $INCREMENT version number"
  VERSION=$(git_version)
  # VERSION="0.0.0"
  info "Current version is $VERSION"
  # replace points, split into array
  V=( ${VERSION//./ } )
  # increment revision (or other part)
  # ((V[$I]++))
  # compose new version
  if [ "$INCREMENT" == "MAJOR" ]; then
    # ((V[0]++))
    var=${V[0]}
    V[0]=$((++var))
    V[1]="0"
    V[2]="0"
    # info "var=$var"
    VERSION="${V[0]}.${V[1]}.${V[2]}"
  elif [ "$INCREMENT" == "MINOR" ]; then
    # ((V[1]++))
    var=${V[1]}
    V[1]=$((++var))
    V[2]="0"
    VERSION="${V[0]}.${V[1]}.${V[2]}"
  else
    # ((V[2]++))
    var=${V[2]}
    V[2]=$((++var))
    VERSION="${V[0]}.${V[1]}.${V[2]}"
  fi
  info "New version is $VERSION"
else
  VERSION=$1
  # replace points, split into array
  V=( ${VERSION//./ } )
fi
BRANCH=$(git rev-parse --abbrev-ref HEAD)
info "Current branch is \"$BRANCH\""
TAG="v$VERSION"
git_chk

cat <<EOM

this script is going to:

  * modify and commit "$DEFS" (${V[0]}.${V[1]}.${V[2]});
  * annotate local repo as v${V[0]}.${V[1]}.${V[2]};
  * push updated "$DEFS" and v${V[0]}.${V[1]}.${V[2]} annotation to remote repo

EOM
if [ "$DRYRUN" -eq "1" ]; then
  exit 0
fi
warn_read "press «RETURN» to continue or «CTRL-C» to exit"

# update defs.scad
sed -i.bak -e "s/function fl_version() = \[[[:digit:]]\+,[[:digit:]]\+,[[:digit:]]\+\];/function fl_version() = \[${V[0]},${V[1]},${V[2]}\];/g" "$DEFS"
# update docs for foundation ($OFL/foundation/docs/dependencies.svg)
$OFL/bin/deps.sh -s
# and vitamins ($OFL/vitamins/docs/dependencies.svg)
$OFL/bin/deps.sh -v -s

git commit -m "Version $VERSION bumped" -a
git tag -m "Version $VERSION bumped" $TAG $BRANCH
git push --follow-tags
