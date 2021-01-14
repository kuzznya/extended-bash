#!/bin/bash

[[ -z "$IMPORT_CORE" ]] && IMPORT_CORE=true || return 0

# import <script path>
# Load script from path
# Return 0 if script was loaded or -1 if not
import() {
  if [[ -f "$1" ]] ; then
    source "$1" && return 0 || return 255
  else
    return 255
  fi
}

# require <script path>
# Load script from path or call missing_script
require() {
    if ! import errors.sh ; then
	echo "Fatal error: missing script errors.sh" > /dev/stderr && exit 245
    fi

    if ! import "$1" ; then
      missing_script "$1"
    fi
}

# call <script path> <func>
# call function from script
call() {
  require "$1"
  args=( $@ )
  args=("${args[@]:2:100}")
  eval "$2" "${args[@]}"
}

# Print program manual
print_man() {
  file_exists man.txt && cat man.txt
}

# replace_first <regex> <value> <source>
# Replace first match of regex in source with value
replace_first() {
  local str="$3"
  echo "${str/$1/$2}"
}

# replace_all <regex> <value> <source>
# Replace all matches of regex in source to value
replace_all() {
  local str="$3"
  echo "${str//$1/$2}"
}

# foreach <command>
# Execute command for each value of input
foreach() {
  while read -r value; do
    eval "$* $value"
  done
}

# foreach_str <command>
# Execute command for each line of input
foreach_str() {
  while read -r value; do
    eval "$* '$value'"
  done
}

# is_int <value>
# Return 0 if value is int, else return -1
is_int() {
  [[ "$1" =~ ^[-+]?([1-9][0-9]*|0)$ ]] && return 0 || return 255
}

# make_list <args>...
# echo each argument (so that data can be easily iterated through)
make_list() {
  for i in "$@" ; do
    echo "$i"
  done
}

# contains <value>
# Return 0 if input stream contains value, else return -1
contains() {
  while read -r line ; do
    [[ "$1" -eq "$line" ]] && return 0
  done
  return 255
}

file_exists() {
  [[ -f "$1" ]] && return 0 || return 255
}

file_writable() {
  [[ -w "$1" ]] && return 0 || return 255
}

dir_exists() {
  [[ -d "$1" ]] && return 0 || return 255
}

# context_runner
# Run user commands in context (interactive console)
# Exit on 'exit' command
context_runner() {
  while true; do
    printf "> "
    read -r line
    [[ "$line" == exit ]] && exit 0
    eval "$line"
  done
}

require errors.sh

[[ "$1" == console ]] && context_runner
