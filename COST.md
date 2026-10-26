# AWS Pricing Calculator estimate

Created October 25, 2026 for US West (Oregon).

[Open saved AWS Pricing Calculator estimate](https://calculator.aws/#/estimate?id=bb2a75426d33c8a78f4bf4e89be9b60eb51b9e7e)

Displayed total: **USD 0.14/month**, USD 0.00 upfront, USD 1.68 over 12 months. Small service subtotals round to cents; this is an estimate, not actual account billing.

| Service | Assumptions | Displayed monthly cost |
|---|---|---:|
| Lambda | 1,000 invocations, x86, 128 MB, 1,000 ms each; no provisioned concurrency; without free tier | $0.00 |
| S3 Standard | Both buckets combined: 1 GB stored, 2,000 PUT/COPY/POST/LIST and 2,000 GET requests | $0.03 |
| DynamoDB | Standard, on-demand, 0.01 GB, 1 KB average items, 1,000 standard writes and 1,000 eventually consistent reads | $0.00 |
| CloudWatch | 0.01 GB standard log ingestion and one standard-resolution alarm metric | $0.11 |

No paid support, NAT gateway, load balancer, provisioned concurrency, cross-Region traffic or large internet downloads are modeled. Taxes and actual usage can change the bill. Same-Region processing is assumed. Log storage and retries are small but not a precise measured bill; use a $1/month planning allowance at this scale and re-estimate before growth. The deployed DynamoDB table uses AWS-managed encryption; IAM and CloudFormation have no modeled additional service charge for these AWS resources.

Applied optimizations: event-driven Lambda avoids an idle EC2 instance; DynamoDB on-demand avoids provisioned idle capacity; CloudWatch logs expire after seven days. Delete the demonstration stack after collecting evidence. For sustained use, add S3 lifecycle expiration and measure execution duration before tuning memory.
