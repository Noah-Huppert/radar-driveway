#!/usr/bin/env bash
# Static variables
source "$(dirname "$(realpath "$0")")/../../scripts/common.sh"

declare -r REMOTE_FILE="/tmp/radar_ctl"

declare -ri EXIT_UNKNOWN_OPT=110
declare -ri EXIT_BUILD=111
declare -ri EXIT_UPLOAD=112
declare -ri EXIT_RUN=113

# Show help text
show_help() {
    cat <<EOF
dev.sh - Build, upload, and run

USAGE

  dev.sh [-h]

OPTIONS

  -h    Show help text

BEHAVIOR

  Build project, then upload the result and run it on the Raspberry Pi.

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
run_check "$EXIT_BUILD" "Failed to build" \
		"$RUST_PROJ_ROOT/scripts/build.sh"

# Upload
run_check "$EXIT_BUILD" "Failed to upload" \
		"$RUST_PROJ_ROOT/scripts/upload.sh "$RUST_BUILD_OUT_FILE" "$REMOTE_FILE""

# Run
run_check "$EXIT_BUILD" "Failed to run" \
		"$RUST_PROJ_ROOT/scripts/ssh.sh "$REMOTE_FILE""
