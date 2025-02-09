# Local Values
locals {
  tfstate_bucket_name = "${var.env}-${var.project}-tfstate"
}

# S3 Bucket for Terraform tfstate

resource "aws_s3_bucket" "tfstate" {
  bucket = local.tfstate_bucket_name
  force_destroy = false
  tags = {
    Name = local.tfstate_bucket_name
  }
}