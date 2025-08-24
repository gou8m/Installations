#!/bin/bash

# Update and install CloudWatch Agent
echo "Updating system and installing CloudWatch Agent..."
sudo apt-get update -y
sudo apt-get install -y amazon-cloudwatch-agent

# Create config directory if not exists
sudo mkdir -p /opt/aws/amazon-cloudwatch-agent/bin/

# Write config.json
cat <<EOF | sudo tee /opt/aws/amazon-cloudwatch-agent/bin/config.json > /dev/null
{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/*",
            "log_group_name": "LOG-FROM-EC2",
            "log_stream_name": "{instance_id}",
            "retention_in_days": 1
          }
        ]
      }
    }
  },
  "metrics": {
    "append_dimensions": {
      "InstanceId": "\${aws:InstanceId}"
    },
    "metrics_collected": {
      "mem": {
        "measurement": [
          "mem_used_percent"
        ],
        "metrics_collection_interval": 60
      },
      "disk": {
        "measurement": [
          "used_percent"
        ],
        "metrics_collection_interval": 60,
        "resources": [
          "/"
        ]
      },
      "swap": {
        "measurement": [
          "swap_used_percent"
        ],
        "metrics_collection_interval": 60
      }
    }
  }
}
EOF

# Start CloudWatch Agent with custom config
echo "Starting CloudWatch Agent..."
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config \
  -m ec2 \
  -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json \
  -s

echo "CloudWatch Agent setup completed successfully!"
