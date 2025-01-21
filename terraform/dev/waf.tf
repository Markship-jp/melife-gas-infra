# -----------------------------
# Locals
# -----------------------------
locals {
  allowed_ips = [
    "123.253.152.115/32",
    "150.195.208.121/32",
    "140.82.207.200/32"
  ]
  api_webacl_name        = "${var.env}-${var.project}-api-webacl"
  cloudfront_webacl_name = "${var.env}-${var.project}-cloudfront-webacl"
  cloudfront_allowed_ips = "${var.env}-${var.project}-cloudfront-allowed-ips"
  maintenance_rule_name  = "${var.env}-${var.project}-maintenance-rule"
}

# -----------------------------
# IPセット
# -----------------------------
resource "aws_wafv2_ip_set" "cloudfront_allowed_ips" {
  provider           = aws.n-virginia # CloudFront用はバージニア北部を指定する必要がある。
  name               = local.cloudfront_allowed_ips
  scope              = "CLOUDFRONT" # ALB用には "REGIONAL" を使用。CloudFront用には "CLOUDFRONT" を使用。
  ip_address_version = "IPV4"
  addresses          = local.allowed_ips
  tags = {
    Name = local.cloudfront_allowed_ips
  }
}

# -----------------------------
# WEB ACL
# -----------------------------
# CloudFront
resource "aws_wafv2_web_acl" "cloudfront" {
  provider = aws.n-virginia # CloudFront用はバージニア北部を指定する必要がある。
  name     = local.cloudfront_webacl_name
  scope    = "CLOUDFRONT" # ALB用には "REGIONAL" を使用。CloudFront用には "CLOUDFRONT" を使用。

  default_action {
    allow {}
  }

  rule {
    name     = "MAINTENANCE"
    priority = 0

    statement {
      rule_group_reference_statement {
        arn = aws_wafv2_rule_group.cloudfront_maintenance.arn
      }
    }

    override_action {
      none {}
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "MAINTENANCE"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = local.cloudfront_webacl_name
    sampled_requests_enabled   = true
  }

  tags = {
    Name = local.cloudfront_webacl_name
  }

  # lifecycle {
  #   ignore_changes = [
  #     rule
  #   ]
  # }
}

# CloudFrontへのWAFの関連付けはcloudfront_distributionで定義する

# CloudFrontメンテナンスページ表示用ルール
resource "aws_wafv2_rule_group" "cloudfront_maintenance" {
  provider = aws.n-virginia
  name     = local.maintenance_rule_name
  scope    = "CLOUDFRONT"
  capacity = 100
  rule {
    name     = "RULE_FOR_MAINTENANCE"
    priority = 0
    action {
      block {
        custom_response {
          response_code            = 503
          custom_response_body_key = "maintenance"
        }
      }
    }
    statement {
      not_statement {
        statement {
          ip_set_reference_statement {
            arn = aws_wafv2_ip_set.cloudfront_allowed_ips.arn
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "RULE_FOR_MAINTENANCE"
      sampled_requests_enabled   = true
    }
  }
  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = local.maintenance_rule_name
    sampled_requests_enabled   = true
  }

  custom_response_body {
    content      = "Maintenance"
    content_type = "TEXT_HTML"
    key          = "maintenance"
  }
  #   lifecycle {
  #     ignore_changes = all
  #   }
}

resource "aws_wafv2_web_acl_logging_configuration" "waf_logs" {
  provider                = aws.n-virginia
  log_destination_configs = [aws_s3_bucket.waf_logs.arn]
  resource_arn            = aws_wafv2_web_acl.cloudfront.arn
}
