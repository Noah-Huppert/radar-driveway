#!/usr/bin/env bash
# Consants
source "$(dirname "$(realpath "$0")")/common.sh"

declare -r DHCPD_CONF_FILE="$PROG_DIR/dhcpd.conf"
declare -r DHCPD_LEASE_FILE="$RUN_TMP_DIR/leases"
declare -r DHCPD_PID_FILE="$RUN_TMP_DIR/dhcpd.pid"

declare -ri EXIT_UKNOWN_OPT=110
declare -ri EXIT_TOUCH_LEASE_FILE=111
declare -ri EXIT_SHOW_ADDR=112
declare -ri EXIT_ADD_ADDR=113

# Show help text
show_help() {
    cat <<EOF
dhcp-server.sh - Run a DHCP server

USAGE

  dhcp-server.sh [-h]

OPTIONS

  -h    Show help text

BEHAVIOR

  Run a DHCP server.

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

# Create lease file to work with
run_check "$EXIT_TOUCH_LEASE_FILE" "Failed to make DHCP server lease file" \
		"touch "$DHCPD_LEASE_FILE""

# Associate the $SUBNET_CIDR subnet with the network interface
if ! run_check "$EXIT_SHOW_ADDR" "Failed to list addresses for '$NETWORK_INTERFACE'" "ip addr show "$NETWORK_INTERFACE"" | grep "$SUBNET_CIDR" &> /dev/null; then
    log "using sudo to set an address for '$NETWORK_INTERFACE'"
    run_check "$EXIT_ADD_ADDR" "Failed to add private subnet CIDR '$SUBNET_CIDR' to interface '$NETWORK_INTERFACE'" \
		    "sudo ip addr add "$SUBNET_CIDR" dev "$NETWORK_INTERFACE""
else
    log "Network interface '$NETWORK_INTERFACE' already associated with '$SUBNET_CIDR'"
fi

# Start the DHCP server
log "using sudo to run the DHCP server"
run_check "$EXIT_RUN_DHCPD" "Failed to run DHCP server on '$NETWORK_INTERFACE'" \
		"sudo dhcpd -f -d -cf "$DHCPD_CONF_FILE" -pf "$DHCPD_PID_FILE" -lf "$DHCPD_LEASE_FILE" -user "$USER" -group "$USER" "$NETWORK_INTERFACE" |& prefix_input dhcpd"
