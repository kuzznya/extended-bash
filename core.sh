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

require errors.sh
