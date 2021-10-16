#!/usr/bin/env bash
# Static variables
declare -r PROG_DIR=$(dirname $(realpath "$0"))
declare -r RUST_PROJ_ROOT="$PROG_DIR/.."
declare -r REPO_DIR="$PROG_DIR/../.."
declare -r ENV_FILE="$REPO_DIR/.env"
declare -r RUST_TARGET="armv7-unknown-linux-gnueabihf"

declare -r BUILD_OUT_FILE="$RUST_PROJ_ROOT/target/$RUST_TARGET/debug/radar_ctl"
declare -r REMOTE_FILE="/tmp/radar_ctl"

# Load configuration
source "$ENV_FILE"

declare -r PI_SSH_URI="${PI_USER}@${PI_HOSTNAME}.local"

# Build
if ! "$PROG_DIR/build.sh"; then
    echo "failed to build" >&2
    exit 1
fi

# Upload
if ! rsync "$BUILD_OUT_FILE" "$PI_SSH_URI:$REMOTE_FILE"; then
    echo "failed to upload" >&2
    exit 1
fi

# Run
if ! ssh "$PI_SSH_URI" "$REMOTE_FILE"; then
    echo "failed to run on pi" >&2
    exit 1
fi
