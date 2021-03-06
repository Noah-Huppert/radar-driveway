#!/usr/bin/env bash
# Constants
source "$(dirname "$(realpath "$0")")/../../scripts/common.sh"

declare -ri EXIT_UKNOWN_OPT=110
declare -ri EXIT_CARGO_BUILD=111

# Show help text
show_help() {
    cat <<EOF
build.sh - Build Rust project

USAGE

  build.sh [-h]

OPTIONS

  -h    Show help text

BEHAVIOR

  Build Rust project for the cross compile target.

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

# Build
run_check "$EXIT_CARGO_BUILD" "Failed to build" \
		"cd "$RUST_PROJ_ROOT" && cargo build --target "$RUST_TARGET" |& prefix_input 'cargo build'"
