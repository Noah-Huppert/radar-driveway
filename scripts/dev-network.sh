#!/usr/bin/env bash
# Constants
source "$(dirname "$(realpath "$0")")/common.sh"

declare -ri EXIT_BAD_SVC=110
declare -ri EXIT_UKNOWN_OPT=111

# Show help text
show_help() {
    cat <<EOF
dev-network.sh - Run a development network

USAGE

  dev-network.sh [-h]

OPTIONS

  -h    Show help text

BEHAVIOR

  Runs services required to create a development network.

EOF
    exit 0
}

# Programs to run which make up dev network
declare -ra SVCS=("dhcp-server.sh" "mdns-server.sh")

declare -a wait_pids=() # string "tuples" in format "svc_name pid"

# Options
while getopts "h" opt; do
    case "$opt" in
	   h) show_help ;;
	   '?') die "$EXIT_UNKNOWN_OPT" "Unknown option" ;;
    esac
done

# Wait for services
wait_svcs() {
    for pid_tuple in "${wait_pids[@]}"; do
	   svc_name=$(awk '{ print $1 }' <<< "$pid_tuple")
	   svc_pid=$(awk '{ print $2 }' <<< "$pid_tuple")

	   log "waiting for $svc_name ($svc_pid)"
	   wait "$svc_pid"
	   log "killed $svc_name (exit status $?)"
    done
}

# Validate services
for svc in "${SVCS[@]}"; do
    svc_file="$PROG_DIR/$svc"
    
    if ! [[ -f "$svc_file" ]]; then
	   die "$EXIT_BAD_SVC" "$svc does not exist"
    fi
done

# Start services
for svc in "${SVCS[@]}"; do
    svc_file="$PROG_DIR/$svc"
    
    "$svc_file" &
    pid=$!
    wait_pids+=("$svc $pid")
    
    log "started $svc ($pid)"
done

# When script receives ctrl+c gracefully stop services
trap "log gracefully stopping" SIGINT

wait_svcs
