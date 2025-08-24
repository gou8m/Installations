#!/bin/bash

# Exit on error
set -e

# ------------------ Node Exporter Installation ------------------
NODE_EXPORTER_VERSION="1.8.1"

# Download Node Exporter
wget https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXPORTER_VERSION}/node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz

# Extract tarball
tar xvfz node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz
cd node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64/

# Move binary to /usr/local/bin
sudo mv node_exporter /usr/local/bin/

# Create node_exporter user
sudo useradd --no-create-home --shell /bin/false node_exporter

# Create systemd service
sudo tee /etc/systemd/system/node_exporter.service > /dev/null <<EOL
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOL

# Reload systemd and start service
sudo systemctl daemon-reload
sudo systemctl enable node_exporter
sudo systemctl start node_exporter

# Cleanup
cd ..
rm -rf node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64*
echo "Node Exporter installation completed!"
