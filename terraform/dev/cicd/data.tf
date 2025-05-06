# Current AWS Account ID
data "aws_caller_identity" "current" {}
# Current User ID with AWS Account
data "aws_canonical_user_id" "current" {}
# Current Region
data "aws_region" "current" {}

# Get outputs from infra module
data "terraform_remote_state" "infra" {
  backend = "s3"
  config = {
    bucket = "dev-melife-gas-tfstate"
    key    = "terraform.tfstate"
    region = "ap-northeast-1"
  }
}