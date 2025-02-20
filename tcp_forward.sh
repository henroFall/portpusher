#!/bin/bash

# Load configuration
source /root/tcp_forward.conf

# Kill any existing socat instances
pkill socat

# Ensure ports are valid
if [[ -z "$IN_PORT" || -z "$OUT_PORT" || -z "$DEST_HOST" ]]; then
    echo "Error: Missing configuration variables."
    exit 1
fi

echo "Starting Port Pusher on port $IN_PORT forwarding to $DEST_HOST:$OUT_PORT"

# Infinite loop to keep `socat` running
while true; do
    socat TCP-LISTEN:$IN_PORT,fork TCP:$DEST_HOST:$OUT_PORT
    echo "socat crashed or stopped, restarting..."
    sleep 2  # Short delay to prevent rapid restart loops
done
