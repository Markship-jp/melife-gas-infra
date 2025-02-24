# Current AWS Account ID
data "aws_caller_identity" "current" {}
# Current User ID with AWS Account
data "aws_canonical_user_id" "current" {}
# Current Region
data "aws_region" "current" {}
data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = ["${var.env}-${var.project}-vpc"]
  }
}