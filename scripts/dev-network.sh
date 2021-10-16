#!/usr/bin/env bash
# Static variables
declare -r PROG_DIR=$(dirname $(realpath "$0"))
declare -ra SVCS=("dhcp-server.sh" "mdns-server.sh")

declare -a wait_pids=() # string "tuples" in format "svc_name pid"

# Wait for services
wait_svcs() {
    for pid_tuple in "${wait_pids[@]}"; do
	   svc_name=$(awk '{ print $1 }' <<< "$pid_tuple")
	   svc_pid=$(awk '{ print $2 }' <<< "$pid_tuple")

	   echo "waiting for $svc_name ($svc_pid)"
	   wait "$svc_pid"
	   echo "killed $svc_name (exit status $?)"
    done
}

# Validate services
for svc in "${SVCS[@]}"; do
        svc_file="$PROG_DIR/$svc"
    
    if ! [[ -f "$svc_file" ]]; then
	   echo "$svc does not exist"
    fi
done

# Start services
for svc in "${SVCS[@]}"; do
    svc_file="$PROG_DIR/$svc"
    
    ("$svc_file" |& sed "s/^/$svc: /g") &
    pid=$!
    wait_pids+=("$svc $pid")
    
    echo "started $svc ($pid)"
done

# When script receives ctrl+c gracefully stop services
trap "echo gracefully stopping" SIGINT

wait_svcs
