#!/bin/bash

[[ -z "$IMPORT_ERRORS" ]] && IMPORT_ERRORS=true || return 0

# print_err <message>
# Print message to stderr
print_err() {
    echo "$*" >> /dev/stderr
}

# error_exit <message> [<code>]
# Print message to srderr & then exit with given code
# If no code present, then -1 is returned
error_exit() {
    local message="$1"
    local code="${2:-1}"

    [[ -n "$message" ]] && print_err "Error: $message" || \
	    print_err "Fatal error"

    exit "${code}"
}

# missing_script <missing script name>
# Reports that script is missing
# Exit code -10
missing_script() {
    error_exit "missing script $1" -10
}

# invalid_args <command> <message>
# Prints manual & reports that command args are invalid
# Exit code -9
invalid_args() {
    ! [[ -z "$IMPORT_CORE" ]] && print_man
    error_exit "invalid args for command $1: $2" -9
}
