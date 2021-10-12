#!/usr/bin/env bash
# Static variables
declare -r PROG_DIR=$(dirname $(realpath "$0"))
declare -r ENV_FILE="$PROG_DIR/../.env"

declare -r SUBNET_CIDR="10.0.0.0/24"

declare -r RUN_TMP_DIR="$PROG_DIR/../.run"

declare -r DHCPD_CONF_FILE="$PROG_DIR/../conf/dhcpd.conf"
declare -r LEASE_FILE="$RUN_TMP_DIR/leases"

# Configuration
source "$ENV_FILE"

# Create working directories
mkdir -p "$RUN_TMP_DIR"
touch "$LEASE_FILE"

# Associate the $SUBNET_CIDR subnet with the network interface
echo "using sudo to set an address for '$NETWORK_INTERFACE'"
sudo ip addr add "$SUBNET_CIDR" dev "$NETWORK_INTERFACE"

# Start the DHCP server
echo "using sudo to run the DHCP server"
sudo dhcpd -f -d -cf "$DHCPD_CONF_FILE" --no-pid -lf "$LEASE_FILE" -user "$USER" -group "$USER" "$NETWORK_INTERFACE"
