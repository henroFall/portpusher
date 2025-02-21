#!/bin/bash

# Define variables (leave paths exactly as they were)
LISTEN_PORT=12345  # Change this as needed
TARGET_IP="192.168.1.200"  # Set dynamically by the Web UI
TARGET_PORT=8080  # Change as needed

# Enable IP forwarding (required for transparent proxying)
echo 1 > /proc/sys/net/ipv4/ip_forward

# Clear old iptables rules to prevent duplicates
iptables -t mangle -F
iptables -t nat -F

# Configure TPROXY to preserve the original source IP
iptables -t mangle -A PREROUTING -p tcp --dport $LISTEN_PORT -j TPROXY --tproxy-mark 1/1 --on-port $LISTEN_PORT
iptables -t nat -A POSTROUTING -p tcp --dport $TARGET_PORT -j MASQUERADE

# Ensure marked packets are routed correctly
ip rule add fwmark 1 lookup 100
ip route add local 0.0.0.0/0 dev lo table 100

echo "[✔] Transparent Proxying Enabled on Port $LISTEN_PORT"

# Start the TCP forwarder (no path changes)
python3 tcp_forward.py $LISTEN_PORT $TARGET_IP $TARGET_PORT
