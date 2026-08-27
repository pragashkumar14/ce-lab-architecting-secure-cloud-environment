# monitoring.tf

# CloudTrail
resource "aws_cloudtrail" "main" {
  name                          = "main-trail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail.id
  is_multi_region_trail         = true
  enable_log_file_validation    = true
  include_global_service_events = true

  depends_on = [aws_s3_bucket_policy.cloudtrail]
}

# VPC Flow Logs
resource "aws_flow_log" "main" {
  vpc_id          = aws_vpc.secure.id
  traffic_type    = "ALL"
  iam_role_arn    = aws_iam_role.flow_logs.arn
  log_destination = aws_cloudwatch_log_group.flow_logs.arn
}

# GuardDuty and Security Hub are defined in the lab spec but excluded here:
# this AWS account returned SubscriptionRequiredException (403) for both
# services at the account level, independent of IAM permissions or Terraform
# config. Confirmed the same restriction applies via the console, not just
# the API. Left as documented code below for reference/portfolio purposes.
#
# resource "aws_guardduty_detector" "main" {
#   enable = true
# }
#
# resource "aws_securityhub_account" "main" {}
