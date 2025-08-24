# Auto Discovery with Node Exporter

This guide explains how to configure **Prometheus** to automatically discover and scrape **EC2 instances** in AWS using **EC2 Service Discovery**.  
We will configure Prometheus, attach the required IAM role/policy, and scrape metrics from **Node Exporter** running on EC2 instances.

---

## Prerequisites

- Prometheus installed .
- Node Exporter running on your EC2 instances at port `9100`.
- AWS IAM role or IAM user with **read-only EC2 permissions**.

---

## Prometheus Configuration

Create or update your Prometheus configuration file (`prometheus.yml`) with the following content:

```
sudo vi /etc/prometheus/prometheus.yml
```
paste the following:

```yaml
global:
  scrape_interval: 15s   # How often Prometheus scrapes targets

scrape_configs:
  - job_name: 'node_exporter_ec2'   # Job name for EC2 service discovery
    ec2_sd_configs:
      - region: ap-south-1          # AWS region where EC2 instances are running
        port: 9100                  # Node Exporter port
    relabel_configs:
      # Use the EC2 private IP as the scrape target
      - source_labels: [__meta_ec2_private_ip]
        target_label: __address__
        replacement: ${1}:9100

      # Attach EC2 instance 'Name' tag as a Prometheus label
      - source_labels: [__meta_ec2_tag_Name]
        target_label: ec2_name
```

> Explanation:

```ec2_sd_configs``` → tells Prometheus to dynamically fetch EC2 instances using AWS APIs.

```__meta_ec2_private_ip``` → metadata label from AWS, mapped to Prometheus target address.

```__meta_ec2_tag_Name``` → metadata label for the instance tag Name. This is mapped to a new label ec2_name in Prometheus.

Restart Prometheus

``` sudo systemctl restart prometheus```

---

## Required IAM Permissions

Prometheus must be able to describe EC2 instances and tags.
Create an IAM Role (if running Prometheus on EC2) or an IAM User (if running Prometheus outside AWS) with the following minimal policy:

```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeInstances",
        "ec2:DescribeTags"
      ],
      "Resource": "*"
    }
  ]
}
```

Attach Role to Prometheus Server

---

## Verify Prometheus Targets

Navigate to http://<prometheus-server>:9090/targets

You should see your EC2 instances discovered under the job ```node_exporter_ec2```.
