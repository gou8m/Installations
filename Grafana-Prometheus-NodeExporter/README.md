# Monitoring Stack Setup: Grafana + Prometheus + Node Exporter

<p align="left">
  <strong>Project Dashboard Preview</strong><br>
  
  <img src="https://github.com/user-attachments/assets/8e803ed3-7385-4937-8d2e-38743e8c6fac" 
       alt="Project Screenshot" 
       width="500" />
  <br><small><i>Click the image to view full size.</i></small>

</p>




This guide will help you configure **Grafana**, **Prometheus**, and **Node Exporter** on a single Ubuntu server (or EC2 instance). It also covers adding Prometheus as a data source in Grafana and importing a sample dashboard.

---

## Prerequisites

- Ubuntu 20.04/22.04 server or EC2 instance
- Sudo privileges
- Internet access

> **Installation commands** for Grafana, Prometheus, and Node Exporter are available in the repository:  
> - Grafana & Prometheus: [grafana-prometheus.sh](https://github.com/gou8m/Installations/blob/main/Grafana-Prometheus/grafana-prometheus.sh)  
> - Node Exporter: [node-exporter.sh](https://github.com/gou8m/Installations/blob/main/Grafana-Prometheus/node-exporter.sh)

---

---

## Step 1: Configure Prometheus to scrape Node Exporter

Edit Prometheus config:

```
sudo vi etc/prometheus/prometheus.yml
```


Add Node Exporter target under `scrape_configs`:

```yml
scrape_configs:
  - job_name: 'node_exporter'
    static_configs:
      - targets: ['localhost:9100', '<pvt-ip-one>:9100', '<pvt-ip-two>:9100']
```


> For multiple servers, install Node Exporter on each and add `<IP>:9100` entries here.  
> After editing, restart Prometheus:

```bash
sudo systemctl restart prometheus
```

---

## Step 2: Configure Grafana Data Source

1. Go to `http://<EC2-Public-IP>:3000`  
2. Login (default: `admin/admin`)
3. Change Password
4. On the left-hand menu, click **Connections** (or **Data Sources**)  
5. Click **Add data source**  
6. Select **Prometheus**  
7. Set URL:

http://localhost:9090

7. Click **Save & Test**  
> Grafana should confirm it can connect to Prometheus.

---

## Step 3: Import a Dashboard

1. On the left-hand menu, click **Dashboards → New → Import**  
2. In **Import via Grafana.com ID**, enter:

```1860```

What is 1860?

> This is a Grafana.com dashboard ID. Grafana has a repository of pre-built dashboards for various metrics and systems.

> Dashboard 1860 is a ready-made Prometheus Node Exporter dashboard for monitoring system metrics like CPU, memory, disk usage, and network.


3. Click **Load**, then **Import**  

> You now have a ready-to-use dashboard monitoring your server metrics.

---

## Notes

- Prometheus default port: `9090`  
- Node Exporter default port: `9100`  
- Grafana default port: `3000`  

- For multiple servers:
  1. Install Node Exporter on each server
  2. Add `<IP>:9100` entries in Prometheus `prometheus.yml`
  3. Restart Prometheus after editing

---
## Stress Testing the Server

The following commands install the `stress` tool and simulate CPU and memory load on your servers for practice purposes. This is useful for:

- Testing Node Exporter metrics in Prometheus
- Observing Grafana dashboard updates under load
- Practicing resource monitoring and alerting

```bash
sudo apt update
sudo apt install -y stress
stress --vm 1 --vm-bytes 512mb --vm-keep --timeout 60s
stress --cpu 1 --timeout 60
```

In Grafana dashboard, change IPs to view different EC2 loads.

---

## References

- [Prometheus Official Docs](https://prometheus.io/docs/introduction/overview/)  
- [Grafana Official Docs](https://grafana.com/docs/grafana/latest/)  
- [Node Exporter GitHub](https://github.com/prometheus/node_exporter)
