#!/usr/bin/env bash

# Constants
declare -r PROG_DIR
PROG_DIR=$(dirname "$(realpath "${BASH_SOURCE[0]}")")

declare -r REPO_ROOT="$PROG_DIR/.."
declare -r ENV_CONF_FILE="$REPO_ROOT/.env"

declare -ri EXIT_MISSING_COMMON_BINS=100
declare -ri EXIT_INCORRECT_COMMON_BINS=101
declare -ri EXIT_CONF_FILE=102

# Ensure a binaries exists in the path.
# If any binaries are missing false is returned, and the binaries which are missing are printed to stdout.
ensure_bins() { # ( bins... )
    local -ra bins=("$@")

    local -a missing_bins=()

    for bin in "${bins[@]}"; do
	   if ! which "$bin" &> /dev/null; then
		  missing_bins+=("$bin")
	   fi
    done

    if (( ${#missing_bins[@]} > 0 )); then
	   echo "${missing_bins[*]}"
	   return "$(false)"
    fi

    return "$(true)"
}

# Ensure a binary is of a certain type (ex., GNU vs BSD). The type_cmd is a command to run which outputs text which includes the type. The type_str is the string which should be searched for in the type_cmd command output.
# Returns false if not correct type.
ensure_bin_type() { # ( type_cmd, type_str )
    local -r type_cmd="$1"
    local -r type_str="$2"

    if ! "$type_cmd" | grep "$type_str" &> /dev/null; then
	   return "$(false)"
    fi

    return "$(true)"
}

# Output message to stdout.
log() { # ( msg )
    local -r msg="$1"
    
    local date_str
    if ! date_str=$(date --iso-8601=seconds); then
	   date_str="<failed to get date>"
    fi

    echo "$date_str $msg"
}

# Output message to stderr.
elog() { # ( msg )
    local -r msg="$1"

    log "$msg" >&2
}

# Exit with message to stderr and code.
die() { # ( exit_code, msg )
    local -ri exit_code="$1"
    local -r msg="$2"

    elog "Error: $msg"
    exit "$exit_code"
}

# Run a command, if it fails die with exit_code and msg.
run_check() { # ( exit_code, msg, cmd )
    local -ri exit_code="$1"
    local -r msg="$2"
    local -r cmd="$3"

    if ! eval "$cmd"; then
	   die "$exit_code" "$msg"
    fi
}

# Run commands and returns false if any fail. Short circuits and returns as soon as one command fails.
all() { # ( cmds... )
    local -ra cmds=("$@")

    for cmd in "${cmds[@]}"; do
	   if ! "$cmd"; then
		  return "$(false)"
	   fi
    done

    return "$(true)"
}

# Outputs the Raspberry Pi SSH connection string.
ssh_conn_str() {
    echo "${PI_USER}@${PI_HOSTNAME}.local"
}

# Ensure binaries used by this file exist
run_check "$EXIT_MISSING_COMMON_BINS" "Missing binaries" \
		"ensure_bins grep awk date"

run_check "$EXIT_INCORRECT_COMMON_BINS" "Binaries are the wrong variety" \
		"ensure_bin_type 'date --help' 'GNU'"

# Load configuration file
run_check "$EXIT_CONF_FILE" "Failed to source configuration .env file" "source $ENV_CONF_FILE"
