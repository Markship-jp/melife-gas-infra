
locals {
  cname               = [""]
  acm_certificate_arn = ""
  vpc_origin_name     = "${var.env}-${var.project}-vpc-origin-alb-http"
}

resource "aws_cloudfront_vpc_origin" "private_alb_http" {
  vpc_origin_endpoint_config {
    name                   = local.vpc_origin_name
    arn                    = aws_lb.main.arn
    http_port              = 80
    https_port             = 443
    origin_protocol_policy = "http-only"

    origin_ssl_protocols {
      items    = ["TLSv1.2"]
      quantity = 1
    }

  }
}

data "aws_security_group" "vpc_origin_sg" {
  name = "CloudFront-VPCOrigins-Service-SG"
}
resource "aws_vpc_security_group_ingress_rule" "vpc_origin" {
  security_group_id            = aws_security_group.alb.id
  from_port                    = 80
  ip_protocol                  = "tcp"
  to_port                      = 80
  referenced_security_group_id = data.aws_security_group.vpc_origin_sg.id
}

resource "aws_cloudfront_distribution" "distribution" {
  enabled = true
  #   aliases             = local.cname
  web_acl_id = aws_wafv2_web_acl.cloudfront.arn

  origin {
    domain_name = aws_lb.main.dns_name
    origin_id   = "albOrigin"
    vpc_origin_config {
      vpc_origin_id = aws_cloudfront_vpc_origin.private_alb_http.id
    }
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "albOrigin"

    viewer_protocol_policy   = "redirect-to-https"
    origin_request_policy_id = "33f36d7e-f396-46d9-90e0-52428a34d9dc" # AllViewerAndCloudFrontHeaders-2022-06
    cache_policy_id          = data.aws_cloudfront_cache_policy.nocache_policy.id
  }

  price_class = "PriceClass_All"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true # ACMの証明書を使用する場合はfalseにする
    # acm_certificate_arn      = local.acm_certificate_arn
    # ssl_support_method       = "sni-only"
    # minimum_protocol_version = "TLSv1"
  }

  logging_config {
    bucket          = aws_s3_bucket.cloudfront_access_logs.bucket_domain_name
    prefix          = "${var.env}-${var.project}/"
    include_cookies = true
  }

}

data "aws_cloudfront_cache_policy" "Managed-CachingOptimized" {
  name = "Managed-CachingOptimized"
}

data "aws_cloudfront_cache_policy" "nocache_policy" {
  name = "Managed-CachingDisabled"
}
