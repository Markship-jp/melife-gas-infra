# Local variables

locals {
  # フロントエンド向けALBのアクセスログ用バケット
  s3_name_alb_access_logs = "${var.env}-${var.project}-alb-access-logs"
  s3_name_lifecycle_rule  = "${var.env}-${var.project}-lifecycle-rule"
  # s3_name_user_upload     = "${var.env}-${var.project}-user-upload"
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

# # ------------------------------------
# # アップロードファイル格納用バケット
# # ------------------------------------

# resource "aws_s3_bucket" "user_upload" {
#   bucket = local.s3_name_user_upload

#   tags = {
#     Name = local.s3_name_user_upload
#   }
# }

# # パブリックブロックアクセス設定

# resource "aws_s3_bucket_public_access_block" "user_upload" {
#   bucket                  = aws_s3_bucket.user_upload.id
#   block_public_acls       = true
#   block_public_policy     = true
#   ignore_public_acls      = true
#   restrict_public_buckets = true
# }

# # 暗号化設定

# resource "aws_s3_bucket_server_side_encryption_configuration" "user_upload" {
#   bucket = aws_s3_bucket.user_upload.bucket

#   rule {
#     apply_server_side_encryption_by_default {
#       sse_algorithm = "AES256"
#     }
#   }
# }

# # ACL無効化

# resource "aws_s3_bucket_ownership_controls" "user_upload" {
#   bucket = aws_s3_bucket.user_upload.bucket

#   rule {
#     object_ownership = "BucketOwnerEnforced"
#   }
# }

# # バージョニング有効化
# resource "aws_s3_bucket_versioning" "user_upload" {
#   bucket = aws_s3_bucket.user_upload.id
#   versioning_configuration {
#     status = "Enabled"
#   }
# }