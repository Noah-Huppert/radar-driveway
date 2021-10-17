#!/usr/bin/env bash
# Constants
source "$(dirname "$(realpath "$0")")/common.sh"

declare -r AVAHI_CONF_FILE="$RUN_TMP_DIR/avahi.conf"

declare -ri EXIT_UKNOWN_OPT=110
declare -ri EXIT_SET_AVAHI_CONF=111
declare -ri EXIT_RUN_AVAHI=112

# Show help text
show_help() {
    cat <<EOF
mdns-server.sh - Run a mDNS server

USAGE

  mdns-srever.sh [-h]

OPTIONS

  -h    Show help text

BEHAVIOR

  Run a mDNS server.

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
