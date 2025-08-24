#!/bin/bash
# Install Node Exporter on Amazon Linux 2023

set -e

NODE_EXPORTER_VERSION="1.8.1"
cd /opt
sudo curl -LO "https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXPORTER_VERSION}/node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz"
sudo tar -xvzf "node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz"
sudo mv "node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64" node_exporter
sudo useradd --no-create-home --shell /bin/false node_exporter
sudo cp /opt/node_exporter/node_exporter /usr/local/bin/

# Systemd service
cat <<EOF | sudo tee /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=node_exporter
ExecStart=/usr/local/bin/node_exporter
Restart=always

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now node_exporter
