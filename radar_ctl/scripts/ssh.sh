#!/usr/bin/env bash
# Constants
source "$(dirname "$(realpath "$0")")/../../scripts/common.sh"

declare -ri EXIT_UKNOWN_OPT=110
declare -ri EXIT_SSH=111

# Show help text
show_help() {
    cat <<EOF
ssh.sh - SSH into Raspberry Pi

USAGE

  ssh.sh [-h] ARGS...

OPTIONS

  -h    Show help text

ARGUMENTS

  ARGS...    Arguments to pass to SSH.

BEHAVIOR

  SSH's into Raspberry Pi.

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

run_check "$EXIT_SSH" "Failed to ssh" \
		"ssh $(ssh_conn_str) $@"
