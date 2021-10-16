#!/usr/bin/env bash
# Static variables
declare -r PROG_DIR=$(dirname $(realpath "$0"))
declare -r RUST_PROJ_ROOT="$PROG_DIR/.."
declare -r RUST_TARGET="armv7-unknown-linux-gnueabihf"

set -x
cd "$RUST_PROJ_ROOT" && cargo build --target "$RUST_TARGET"
