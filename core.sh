#!/bin/bash

[[ -z "$IMPORT_CORE" ]] && IMPORT_CORE=true || return 0

# import <script path>
# Load script from path
# Return 0 if script was loaded or -1 if not
import() {
    if [[ -f "$1" ]] ; then
	source "$1" && return 0 || return -1
    else
	return -1
    fi
}

#require <script path>
# Load script from path or call missing_script
require() {
    if ! import errors.sh ; then
	echo "Fatal error: missing script errors.sh" > /dev/stderr && exit -10
    fi

    if ! import "$1" ; then
	missing_script "$1"
    fi
}

# Print program manual
print_man() {
    cat man.txt
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
    while read value; do
	eval "$* $value"
    done
}

# foreach_str <command>
# Execute command for each line of input
foreach_str() {
    while read value; do
	eval "$* '$value'"
    done
}

# is_int <value>
# Return 0 if value is int, else return -1
is_int() {
    [[ "$1" =~ ^-?([1-9][0-9]*|0)$ ]] && return 0 || return -1
}

file_exists() {
    [[ -f "$1" ]] && return 0 || return -1
}

dir_exists() {
    [[ -d "$1" ]] && return 0 || return -1
}

require errors.sh
