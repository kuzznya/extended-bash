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

# error <message> [<core>]
# Print message to stderr
# If EXIT_ON_ERROR defined, then exit with given code or -1
error() {
    local message="$1"
    local code="${2:-1}"
    
    [[ -n "$message" ]] && print_err "Error: $message" || \
	    print_err "Error"

    [[ -n "$EXIT_ON_ERROR" ]] && exit "$core"
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

# type_error <message>
type_error() {
    error "Type error: $@" -8
}

instance_error() {
    error "Instance error: $@" -7
}
