# デフォルトリージョンの証明書
resource "aws_acm_certificate" "main" {
  domain_name               = "${var.domain_name}"
  subject_alternative_names = ["*.${var.domain_name}"]
  validation_method         = "DNS"
  key_algorithm             = "RSA_2048"

  tags = {
    Name = "${var.domain_name}"
  }
}

resource "aws_acm_certificate_validation" "main" {
  certificate_arn         = aws_acm_certificate.main.arn
  validation_record_fqdns = [for record in aws_route53_record.main : record.fqdn]
}

# us-east-1リージョンの証明書（CloudFront用）
resource "aws_acm_certificate" "n-virginia" {
  provider                  = aws.n-virginia
  domain_name               = "${var.domain_name}"
  subject_alternative_names = ["*.${var.domain_name}"]
  validation_method         = "DNS"
  key_algorithm             = "RSA_2048"

  tags = {
    Name = "${var.domain_name}"
  }
}

resource "aws_acm_certificate_validation" "n-virginia" {
  provider                  = aws.n-virginia
  certificate_arn           = aws_acm_certificate.n-virginia.arn
  validation_record_fqdns   = [for record in aws_route53_record.main : record.fqdn]
}