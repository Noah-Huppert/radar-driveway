#!/usr/bin/env bash

# Constants
declare -ri TRUE=$(true ; echo $? )
declare -ri FALSE=$(false ; echo $? )

declare -r PROG_DIR=$(dirname "$(realpath "${BASH_SOURCE[0]}")")

declare -r REPO_ROOT="$PROG_DIR/.."
declare -r ENV_CONF_FILE="$REPO_ROOT/.env"
declare -r RUN_TMP_DIR="$REPO_ROOT/.run"

declare -r SUBNET_CIDR="10.0.0.0/24"

declare -r RUST_PROJ_ROOT="$REPO_ROOT/radar_ctl"
declare -r RUST_TARGET="armv7-unknown-linux-gnueabihf"

declare -ri EXIT_MISSING_COMMON_BINS=100
declare -ri EXIT_INCORRECT_COMMON_BINS=101
declare -ri EXIT_CONF_FILE=102
declare -ri EXIT_MK_RUN_DIR=103

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
	   return "$FALSE"
    fi

    return "$TRUE"
}

# Ensure a binary is of a certain type (ex., GNU vs BSD). The type_cmd is a command to run which outputs text which includes the type. The type_str is the string which should be searched for in the type_cmd command output.
# Returns false if not correct type.
ensure_bin_type() { # ( type_cmd, type_str )
    local -r type_cmd="$1"
    local -r type_str="$2"

    if ! eval "$type_cmd" | grep "$type_str" &> /dev/null; then
	   return "$FALSE"
    fi

    return "$TRUE"
}

# Output the log prefix to stdout.
log_prefix() {
    local date_str
    if ! date_str=$(date --iso-8601=seconds); then
	   date_str="<failed to get date>"
    fi

    echo "$date_str"
}

# Output message to stdout.
log() { # ( msg )
    local -r msg="$1"

    echo "$(log_prefix) $msg"
}

# Output message to stderr.
elog() { # ( msg )
    local -r msg="$1"

    log "$msg" >&2
}

# Print the input with a prefix plus the standard log prefix. Pipe using |& to pass stderr to this function.
prefix_input() { # ( prefix )
    local -r prefix="$1"

    cat | sed "s/^/$(log_prefix) $prefix: /g"
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
		  return "$FALSE"
	   fi
    done

    return "$TRUE"
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
if ! source "$ENV_CONF_FILE"; then
    die "$EXIT_CONF_FILE" "Failed to source configuration .env file"
fi

# Create working directories
run_check "$EXIT_MK_RUN_DIR" "Failed to make temporary run directory" \
		"mkdir -p "$RUN_TMP_DIR""
