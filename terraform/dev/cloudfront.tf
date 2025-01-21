
locals {
  cname               = [""]
  acm_certificate_arn = ""
}

resource "aws_cloudfront_distribution" "distribution" {
  enabled = true
  #   aliases             = local.cname
  web_acl_id = aws_wafv2_web_acl.cloudfront.arn

  origin {
    domain_name = aws_lb.main.dns_name
    origin_id   = "albOrigin"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
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

#   logging_config {
#     bucket = aws_s3_bucket.cloudfront_access_logs.bucket_domain_name
#     prefix = "cloudfront/${var.env}-${var.system}-front_app/"

#     include_cookies = true
#   }

}

data "aws_cloudfront_cache_policy" "Managed-CachingOptimized" {
  name = "Managed-CachingOptimized"
}

data "aws_cloudfront_cache_policy" "nocache_policy" {
  name = "Managed-CachingDisabled"
}
