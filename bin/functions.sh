#!/bin/bash

COLOR_GREEN="\e[32m"
COLOR_YELLOW="\e[33m"
COLOR_RED="\e[91m"
COLOR_DEFAULT="\e[39m"

color_message() {
  local c
  [ -n "$REMOTE" ] && c="*" || c="@"
  local color=$1
  shift
  echo -n -e "$color"
  case "$color" in
    "$COLOR_GREEN")
      echo -n "[*INF*]"
      ;;
    "$COLOR_YELLOW")
      echo -n "[*WRN*]"
      ;;
    *)
      echo -n "[*ERR*]"
      ;;
  esac
  echo -e " ${*}${COLOR_DEFAULT}"
}

info() {
  if [ "$VERBOSE" -eq "1" ]; then
    color_message ${COLOR_GREEN} "${1}"
  fi
}

warn() {
  color_message ${COLOR_YELLOW} "${1}"
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
  color_message ${COLOR_RED} "${MSG}"
  exit $RC
}

set_default() {
  local var=$1
  local val=$2
  local def="DEF_$1"
  eval $var="$val"
  eval $def="$val"
}

chk_root_user() {
  if [ "$EUID" -ne 0 ]; then
    fail "Please run as root"
  fi
}

warn_read() {
  local c
  [ -n "$REMOTE" ] && c="*" || c="@"
  echo -n -e "${COLOR_YELLOW}[${c}WRN${c}] ${1}${COLOR_DEFAULT}"
  read
}

my_dot() {
  sed 's%.*%\.%g' | tr -d '\n'
}