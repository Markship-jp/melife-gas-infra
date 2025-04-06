locals {
  cloudtrail_name = "${var.env}-${var.project}-cloudtrail"
}

resource "aws_cloudtrail" "main" {
  name = local.cloudtrail_name
  s3_bucket_name = aws_s3_bucket.cloudtrail_bucket.id
  tags = {
    Name = local.cloudtrail_name
  }
  depends_on = [aws_s3_bucket_policy.cloudtrail_bucket]
}