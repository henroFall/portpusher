#!/bin/bash

# Fail on error
set -e

# Define installation paths
INSTALL_DIR="/opt/portpusher"
SERVICE_DIR="/etc/systemd/system"

# Dependencies
echo "[*] Installing required packages..."
sudo apt update
sudo apt install -y python3 python3-pip iptables git

# Clone or update the repo
if [ -d "$INSTALL_DIR" ]; then
    echo "[*] Updating Port Pusher..."
    cd "$INSTALL_DIR"
    git pull
else
    echo "[*] Cloning Port Pusher..."
    sudo git clone https://github.com/henroFall/portpusher.git "$INSTALL_DIR"
fi

# Change to install directory
cd "$INSTALL_DIR"

# Install Python dependencies
echo "[*] Installing Python dependencies..."
pip3 install -r requirements.txt

# Set executable permissions for scripts
sudo chmod +x start_portpusher.sh

# Copy systemd service files
echo "[*] Installing systemd services..."
sudo cp "$INSTALL_DIR"/services/*.service "$SERVICE_DIR"

# Reload systemd to recognize new services
sudo systemctl daemon-reload

# Enable and start the services
echo "[*] Enabling and starting Port Pusher services..."
for service in "$SERVICE_DIR"/portpusher*.service; do
    sudo systemctl enable "$(basename "$service")"
    sudo systemctl start "$(basename "$service")"
done

echo "[✔] Installation complete! Port Pusher is running and will start on boot."
