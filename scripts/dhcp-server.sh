#!/usr/bin/env bash
set -e # Exit on error

# Static variables
declare -r PROG_DIR=$(dirname $(realpath "$0"))
declare -r ENV_FILE="$PROG_DIR/../.env"

declare -r RUN_TMP_DIR="$PROG_DIR/../.run"

declare -r DHCPD_CONF_FILE="$PROG_DIR/../conf/dhcpd.conf"
declare -r LEASE_FILE="$RUN_TMP_DIR/leases"

# Configuration
source "$ENV_FILE"

# Create working directories
mkdir -p "$RUN_TMP_DIR"
touch "$LEASE_FILE"

# Run server
echo "running dhcpd with sudo"
sudo dhcpd -f -cf "$DHCPD_CONF_FILE" -lf "$LEASE_FILE" -user "$USER" -group "$USER" "$NETWORK_INTERFACE"
