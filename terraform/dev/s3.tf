# Local variables

locals {
  # フロントエンド向けALBのアクセスログ用バケット
  s3_name_alb_access_logs = "${var.env}-${var.project}-alb-access-logs"
  s3_name_lifecycle_rule  = "${var.env}-${var.project}-lifecycle-rule"
  s3_name_storage     = "${var.env}-${var.project}-storage"
  s3_name_waf_logs = "aws-waf-logs-${var.env}-${var.project}"
  s3_name_cloudfront_access_logs = "${var.env}-${var.project}-cloudfront-access-logs"
}

# ------------------------------------
# フロントエンド向けALBのアクセスログ用S3バケット
# ------------------------------------

resource "aws_s3_bucket" "alb_access_logs" {
  bucket = local.s3_name_alb_access_logs

  tags = {
    Name = local.s3_name_alb_access_logs
  }
}

# パブリックブロックアクセス設定

resource "aws_s3_bucket_public_access_block" "alb_access_logs" {
  bucket                  = aws_s3_bucket.alb_access_logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# バケットポリシーをHCL構文で記載、S3バケットに紐づけ

data "aws_iam_policy_document" "alb_access_logs" {
  version = "2012-10-17"
  statement {
    sid       = "AllowAccessLog"
    effect    = "Allow"
    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::${aws_s3_bucket.alb_access_logs.bucket}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"]
    principals {
      type        = "AWS"
      identifiers = ["582318560864"]
    }
  }
}

resource "aws_s3_bucket_policy" "alb_access_logs" {
  bucket = aws_s3_bucket.alb_access_logs.id
  policy = data.aws_iam_policy_document.alb_access_logs.json
}

# 暗号化設定

resource "aws_s3_bucket_server_side_encryption_configuration" "alb_access_logs" {
  bucket = aws_s3_bucket.alb_access_logs.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# ACL無効化

resource "aws_s3_bucket_ownership_controls" "alb_access_logs" {
  bucket = aws_s3_bucket.alb_access_logs.bucket

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# ライフサイクル設定
resource "aws_s3_bucket_lifecycle_configuration" "alb_access_logs" {
  bucket = aws_s3_bucket.alb_access_logs.bucket

  rule {
    status = "Enabled"
    id     = local.s3_name_lifecycle_rule
    transition {
      days          = 60
      storage_class = "STANDARD_IA"
    }
    expiration {
      days = 365
    }
  }
}

# ------------------------------------
# WAFログ格納用バケット
# ------------------------------------

resource "aws_s3_bucket" "waf_logs" {
  bucket = local.s3_name_waf_logs

  tags = {
    Name = local.s3_name_waf_logs
  }
}

# パブリックブロックアクセス設定

resource "aws_s3_bucket_public_access_block" "waf_logs" {
  bucket                  = aws_s3_bucket.waf_logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# 暗号化設定

resource "aws_s3_bucket_server_side_encryption_configuration" "waf_logs" {
  bucket = aws_s3_bucket.waf_logs.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# ACL無効化

resource "aws_s3_bucket_ownership_controls" "waf_logs" {
  bucket = aws_s3_bucket.waf_logs.bucket

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# バージョニング有効化
resource "aws_s3_bucket_versioning" "waf_logs" {
  bucket = aws_s3_bucket.waf_logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

# ライフサイクル設定
resource "aws_s3_bucket_lifecycle_configuration" "waf_logs" {
  bucket = aws_s3_bucket.waf_logs.bucket

  rule {
    status = "Enabled"
    id     = local.s3_name_lifecycle_rule
    transition {
      days          = 60
      storage_class = "STANDARD_IA"
    }
    expiration {
      days = 365
    }
  }
}


# ------------------------------------
# CloudFrontログ格納用バケット
# ------------------------------------

resource "aws_s3_bucket" "cloudfront_access_logs" {
  bucket = local.s3_name_cloudfront_access_logs

  tags = {
    Name = local.s3_name_cloudfront_access_logs
  }
}

# パブリックブロックアクセス設定

resource "aws_s3_bucket_public_access_block" "cloudfront_access_logs" {
  bucket                  = aws_s3_bucket.cloudfront_access_logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# 暗号化設定

resource "aws_s3_bucket_server_side_encryption_configuration" "cloudfront_access_logs" {
  bucket = aws_s3_bucket.cloudfront_access_logs.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# オブジェクト所有者の設定
resource aws_s3_bucket_ownership_controls cloudfront_access_logs {
    bucket = aws_s3_bucket.cloudfront_access_logs.id
    rule {
        object_ownership = "BucketOwnerPreferred"
    }
}
# ACLを設定
resource aws_s3_bucket_acl cloudfront_access_logs {
    bucket = aws_s3_bucket.cloudfront_access_logs.id
    acl    = "private"
    depends_on = [ aws_s3_bucket_ownership_controls.cloudfront_access_logs ]
}

# バージョニング有効化
resource "aws_s3_bucket_versioning" "cloudfront_access_logs" {
  bucket = aws_s3_bucket.cloudfront_access_logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

# ライフサイクル設定
resource "aws_s3_bucket_lifecycle_configuration" "cloudfront_access_logs" {
  bucket = aws_s3_bucket.cloudfront_access_logs.bucket

  rule {
    status = "Enabled"
    id     = local.s3_name_lifecycle_rule
    transition {
      days          = 60
      storage_class = "STANDARD_IA"
    }
    expiration {
      days = 365
    }
  }
}

# ------------------------------------
# アプリケーションストレージバケット
# ------------------------------------

resource "aws_s3_bucket" "storage" {
  bucket = local.s3_name_storage

  tags = {
    Name = local.s3_name_storage
  }
}

# パブリックブロックアクセス設定

resource "aws_s3_bucket_public_access_block" "storage" {
  bucket                  = aws_s3_bucket.storage.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# 暗号化設定

resource "aws_s3_bucket_server_side_encryption_configuration" "storage" {
  bucket = aws_s3_bucket.storage.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# ACL無効化

resource "aws_s3_bucket_ownership_controls" "storage" {
  bucket = aws_s3_bucket.storage.bucket

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# バージョニング有効化
resource "aws_s3_bucket_versioning" "storage" {
  bucket = aws_s3_bucket.storage.id
  versioning_configuration {
    status = "Enabled"
  }
}
