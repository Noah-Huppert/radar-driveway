#!/usr/bin/env bash
# Constants
source "$(dirname "$(realpath "$0")")/common.sh"

declare -r AVAHI_CONF_FILE="$RUN_TMP_DIR/avahi.conf"

declare -ri EXIT_SET_AVAHI_CONF=110
declare -ri EXIT_RUN_AVAHI=111

avahi_conf() {
    cat <<EOF
[server]
allow-interfaces=$NETWORK_INTERFACE
enable-dbus=no
EOF
}

# Dynamically create Avahi configuration file
run_check "$EXIT_SET_AVAHI_CONF" "Failed to write Avahi configuration file" \
		"avahi_conf | tee "$AVAHI_CONF_FILE" &> /dev/null"

# Start the Avahi mDNS Daemon
log "using sudo to start Avahi daemon"
run_check "$EXIT_RUN_AVAHI" "Failed to run Avahi daemon" \
		"sudo avahi-daemon -f "$AVAHI_CONF_FILE" |& prefix_input avahi"
