# Secure Architecture Documentation

## Network Design
- **VPC:** 10.0.0.0/16
- **Public Subnets:** 10.0.1.0/24, 10.0.2.0/24 (ALB only)
- **Private App Subnets:** 10.0.11.0/24, 10.0.12.0/24 (ECS/EC2)
- **Private Data Subnets:** 10.0.21.0/24, 10.0.22.0/24 (RDS, NO internet)

Two Availability Zones (eu-west-3a, eu-west-3b) used throughout for high availability.

## Security Controls

### Defense in Depth Layers
1. **Perimeter:** WAF (OWASP rules) — *not implemented in this lab iteration; see Deviations*
2. **Network:** Security groups (least privilege) — ALB → App → Database chain
3. **Compute:** IAM roles (no access keys) — used for VPC Flow Logs delivery
4. **Data:** Encryption at rest (KMS), in transit (TLS)
5. **Monitoring:** CloudTrail, VPC Flow Logs, GuardDuty — *GuardDuty/Security Hub blocked; see Deviations*

### Encryption
- **RDS:** Encrypted with a dedicated KMS key (`aws_kms_key.rds`)
- **S3 (CloudTrail bucket):** Public access fully blocked at the bucket level; bucket policy restricted to the CloudTrail service principal only
- **ALB:** HTTPS only (443), TLS 1.2+ — ingress rule scoped to 443/tcp from 0.0.0.0/0

### Access Control
- **App Tier:** No SSH access designed into the security group chain; app-sg only accepts 8080/tcp from alb-sg
- **Database:** No public access (`publicly_accessible = false`); security group restricted to app-sg only on 5432/tcp; **no egress rules at all** — database tier cannot reach the internet outbound
- **Secrets:** Database password generated via `random_password` and injected at deploy time, not hardcoded

## Threat Mitigation

| Threat | Mitigation |
|--------|------------|
| SQL Injection | Parameterized queries (application-layer control), WAF |
| Data Breach | Encryption (KMS at rest, TLS in transit), private subnet isolation |
| DDoS | AWS Shield, CloudFront (perimeter layer — not yet implemented) |
| Privilege Escalation | Least-privilege IAM (scoped flow-logs role, no broad permissions) |
| Unauthorized DB access | Security group chain restricts DB to app tier only; no public accessibility |
| Lateral movement | Tiered subnet segmentation; data tier has no route to internet |

## Deployed Resources (Terraform state)
- `aws_vpc.secure`, 6 subnets across 3 tiers × 2 AZs
- `aws_security_group.alb/app/database` + 5 `aws_security_group_rule` resources (split out to avoid a dependency cycle between the three SGs)
- `aws_db_instance.main` (PostgreSQL, encrypted, private, `db.t3.micro`)
- `aws_kms_key.rds`, `aws_db_subnet_group.main`
- `aws_cloudtrail.main` (multi-region, log file validation, global service events) backed by `aws_s3_bucket.cloudtrail`
- `aws_flow_log.main` → `aws_cloudwatch_log_group.flow_logs`, delivered via `aws_iam_role.flow_logs`

## Deviations from Original Spec
- **`backup_retention_period`** reduced from 30 to 1 day — the AWS account used for this build is on the Free Tier plan, which caps backup retention; 30 days would be the production-appropriate value on a standard account.
- **GuardDuty and Security Hub** (`aws_guardduty_detector.main`, `aws_securityhub_account.main`) could not be enabled — both returned `SubscriptionRequiredException` (403) at the account level, confirmed independent of IAM permissions. Terraform code for both is retained (commented) in `monitoring.tf` for reference.
- **WAF and CloudFront** were not implemented in this pass — the lab's perimeter layer is documented above as a design intent but not yet built.

## Submission Checklist
- [x] Complete Terraform code for secure architecture
- [x] `architecture-doc.md` with security annotations
- [ ] Architecture diagram (draw.io or similar)
- [ ] Screenshot of deployed resources
