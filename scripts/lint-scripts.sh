#!/usr/bin/env bash

# Constants
declare -r PROG_DIR=$(dirname $(realpath "$0"))
declare -r REPO_ROOT="$PROG_DIR/.."
declare -r ENV_CONF_FILE="$REPO_ROOT/.env"

declare -ri EXIT_UKNOWN_OPT=110
declare -ri EXIT_SHELLCHECK_MISSING=111

# Show help text
show_help() {
    cat <<EOF
lint-scripts.sh - Upload a file

USAGE

  lint-scripts.sh [-h]

OPTIONS

  -h    Show help text

BEHAVIOR

  Lint all shell scripts in this repository.
  A self contained script which doesn't use any other scripts (since those could have syntax errors which this script is supposed to catch).

EOF
}

# Options
while getopts "h" opt; do
    case "$opt" in
	   h) show_help ;;
	   '?') die "$EXIT_UNKNOWN_OPT" "Unknown option" ;;
    esac
done

if ! which shellcheck &> /dev/null; then
    echo "Error: shellcheck must be installed" >&2
    exit "$EXIT_SHELLCHECK_MISSING"
fi

shellcheck "$ENV_CONF_FILE" $(find . -type f -name "*.sh")
