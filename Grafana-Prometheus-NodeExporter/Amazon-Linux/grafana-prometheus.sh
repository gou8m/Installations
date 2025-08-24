#!/bin/bash
# Install Grafana and Prometheus on Amazon Linux 2023

set -e

# Update system
sudo dnf update -y

# ------------------------
# Install Prometheus
# ------------------------
PROM_VERSION="2.54.1"
cd /opt
sudo curl -LO "https://github.com/prometheus/prometheus/releases/download/v${PROM_VERSION}/prometheus-${PROM_VERSION}.linux-amd64.tar.gz"
sudo tar -xvzf "prometheus-${PROM_VERSION}.linux-amd64.tar.gz"
sudo mv "prometheus-${PROM_VERSION}.linux-amd64" prometheus
sudo useradd --no-create-home --shell /bin/false prometheus
sudo mkdir -p /etc/prometheus /var/lib/prometheus
sudo cp /opt/prometheus/prometheus /usr/local/bin/
sudo cp /opt/prometheus/promtool /usr/local/bin/
sudo cp -r /opt/prometheus/consoles /opt/prometheus/console_libraries /etc/prometheus/
sudo chown -R prometheus:prometheus /etc/prometheus /var/lib/prometheus

# Prometheus config
cat <<EOF | sudo tee /etc/prometheus/prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
EOF

# Prometheus systemd service
cat <<EOF | sudo tee /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus
After=network.target

[Service]
User=prometheus
ExecStart=/usr/local/bin/prometheus \\
  --config.file=/etc/prometheus/prometheus.yml \\
  --storage.tsdb.path=/var/lib/prometheus/
Restart=always

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now prometheus

# ------------------------
# Install Grafana
# ------------------------
sudo tee /etc/yum.repos.d/grafana.repo <<EOF
[grafana]
name=Grafana OSS
baseurl=https://rpm.grafana.com/oss/rpm
repo_gpgcheck=1
enabled=1
gpgcheck=1
gpgkey=https://rpm.grafana.com/gpg.key
EOF

sudo dnf install -y grafana
sudo systemctl enable --now grafana-server
