# Centralized Logging and Monitoring on EC2 Using CloudWatch

When managing EC2 servers, one of the most overlooked but crucial aspects is **log and metric monitoring**.  
If something breaks, logs help us debug. If performance drops, metrics help us catch it before users notice.  

But how do you effectively collect logs and system metrics from multiple EC2 servers and avoid the pain of logging into each one?  

Let’s walk through how to use **Amazon CloudWatch Agent** to pull both logs and metrics, and how to export them to **S3 for cost efficiency and retention management**.  

---

## 1. What is CloudWatch?

CloudWatch is AWS’s monitoring tool for tracking **metrics, logs, events, and alarms** across AWS resources.  

It works out-of-the-box for services like:
- RDS  
- S3  
- Lambda  
- ECS  

But it doesn’t automatically track logs or detailed metrics for **EC2 instances** (like memory, disk usage, etc.). That’s where the **CloudWatch Agent** comes in.  

---

## 2. Installing CloudWatch Agent and Configuring Logs + Metrics

We’ll be using the **cloudwatch_setup.sh** script in this repo to automate installation and configuration.  

Once downloaded, make it executable and run:

```bash

chmod +x cloudwatch_setup.sh
./cloudwatch_setup.sh

```

---
# 3. IAM Role Requirement

Before the CloudWatch agent can push logs or metrics from your EC2 instance, it must have an IAM role attached with the necessary permissions.

## Step-by-Step:

### Create an IAM Role for EC2:
1. Go to **IAM → Roles → Create role**  
2. Trusted entity: **EC2**  
3. Permissions: Attach the managed policy:  
   - **CloudWatchAgentServerPolicy**

### Attach Role to EC2:
1. Go to **EC2 → Instances**  
2. Select your instance → **Actions → Security → Modify IAM Role**  
3. Choose the role you created and save.  

### What the Policy Allows:
- Push custom metrics (`PutMetricData`)  
- Push log data to CloudWatch Logs  
- Read from EC2 metadata (needed for `{instance_id}` dynamic log stream names)  

⚠️ Without this IAM role, even if your agent is configured correctly, logs and metrics won’t show up in CloudWatch.

---

# 4. Why Not Just Store Logs on EC2?

EC2 instances store logs in the EBS volume, and if your applications are chatty or verbose, these logs:  
- Pile up fast  
- Eat your disk space  
- Slow down the server  
- Might even crash the instance over time  

---

# 5. Exporting Logs to S3

Instead of storing logs indefinitely in CloudWatch (which can get expensive) or on EC2 (which can crash), export logs to Amazon S3:  
- **S3 is cheaper**  
- **Scales better**  
- **Offers long-term retention**  

You can set up an export task manually, but automation is better.

---

# 6. Automate Export Using Lambda

- Create a Lambda function that runs on a CloudWatch Events schedule  
- Use IAM roles to allow it to:  
  - Read logs from CloudWatch  
  - Write to your target S3 bucket  

- Logs get archived daily/weekly/monthly to S3 — fully automated.  

This ensures your EC2 stays light, and you retain logs securely.

---

# 7. Summary

- CloudWatch Agent lets you collect both logs and system-level metrics from EC2.  
- Logs are collected from `/var/log/*` and pushed to log groups.  
- Metrics like memory and disk usage aren’t available by default — you need the agent.  
- Use log retention policies to auto-delete old logs.  
- Export logs to S3 for cheaper, long-term storage.  
- Automate exports using AWS Lambda + IAM roles.  

---

# 8. Final Words

Managing a fleet of EC2s doesn’t have to mean SSH-ing into each one for logs or metrics.  

With a simple setup using CloudWatch Agent, you can have:  
- **Full visibility**  
- **Clean storage management**  
- **Peace of mind — all while staying cost-efficient**  

🚀 Start now. Centralize your monitoring, export your logs, and scale smarter.
