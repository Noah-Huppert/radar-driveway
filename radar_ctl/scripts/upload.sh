#!/usr/bin/env bash

# Constants
source "$(dirname "$(realpath "$0")")/../../scripts/common.sh"

declare -ri EXIT_MISSING_BINS=110
declare -ri EXIT_UKNOWN_OPT=111
declare -ri EXIT_RSYNC=112

run_check "$EXIT_MISSING_BINS" "Missing binaries" \
		"ensure_bins rsync"

# Show help text
show_help() {
    cat <<EOF
upload.sh - Upload a file

USAGE

  upload.sh [-h] HOST_FILE REMOTE_FILE

OPTIONS

  -h    Show help text

ARGUMENTS

  HOST_FILE    File on this host machine to upload
  REMOTE_FILE    Location on the remote machine at which to upload HOST_FILE

BEHAVIOR

  Uploads a file to the Pi.

EOF
    exit 0
}

# Options
while getopts "h" opt; do
    case "$opt" in
	   h) show_help ;;
	   '?') die "$EXIT_UNKNOWN_OPT" "Unknown option" ;;
    esac
done

shift $((OPTIND-1))

# Arguments
declare -r HOST_FILE="$1"
declare -r REMOTE_FILE="$2"

run_check "$EXIT_RSYNC" "Failed to upload '$HOST_FILE' to '$REMOTE_FILE'" \
		"rsync "$HOST_FILE" $(ssh_conn_str):"$REMOTE_FILE""
