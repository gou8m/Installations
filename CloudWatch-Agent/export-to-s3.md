# Exporting CloudWatch Logs to S3

This guide explains how to export logs from **Amazon CloudWatch** to an **S3 bucket**.

---

## 1. Prerequisites
- An **S3 bucket** (example: `gou8m-bucket`)
- An **IAM role** attached to your EC2/CloudWatch Logs with `logs:*` permissions
- Your **AWS Account ID**: `9111********`
- Region: `us-east-1`

---

## 2. Add Bucket Policy to S3

1. Go to **S3 → gou8m-bucket → Permissions → Bucket Policy → Edit**
2. Add the following policy:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowCWLogsToWrite",
      "Effect": "Allow",
      "Principal": {
        "Service": "logs.us-east-1.amazonaws.com"
      },
      "Action": "s3:*",
      "Resource": [
        "arn:aws:s3:::gou8m-bucket",
        "arn:aws:s3:::gou8m-bucket/*"
      ],
      "Condition": {
        "StringEquals": {
          "aws:SourceAccount": "9111********"
        }
      }
    }
  ]
}
```
---

## Export Logs via Console

- Open CloudWatch Console
- Go to Log groups
- Select the log group you want
- Click Actions → Export data to Amazon S3
- Choose gou8m-bucket
- Select a time range
- Click Export

---

## Verify Logs in S3

- Go to your S3 bucket
- Logs will appear inside as .gz compressed files
- Download & extract to view logs locally

---

## Notes

- Export jobs may take a few minutes to complete
- Ensure the bucket policy is correctly applied
- CloudWatch Logs must be in the same region as the S3 bucket
