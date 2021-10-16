#!/usr/bin/env bash
# Static variables
declare -r PROG_DIR=$(dirname $(realpath "$0"))
declare -r ENV_FILE="$PROG_DIR/../.env"

declare -r SUBNET_CIDR="10.0.0.0/24"

declare -r RUN_TMP_DIR="$PROG_DIR/../.run"

declare -r AVAHI_CONF_FILE="$RUN_TMP_DIR/avahi.conf"

# Configuration
source "$ENV_FILE"

# Create working directories
mkdir -p "$RUN_TMP_DIR"

# Dynamically create Avahi configuration file
cat <<EOF | tee "$AVAHI_CONF_FILE"
[server]
allow-interfaces=$NETWORK_INTERFACE
enable-dbus=no
EOF

# Start the Avahi mDNS Daemon
echo "using sudo to start Avahi daemon"
sudo avahi-daemon -f "$AVAHI_CONF_FILE"
