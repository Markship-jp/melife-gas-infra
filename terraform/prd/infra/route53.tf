# Route53でドメイン取得時に自動でホストゾーンが作成されるため、importする
import {
  to = aws_route53_zone.main
  id = "Z09646894140W7ISTVS4"
}

resource "aws_route53_zone" "main" {
  name = var.domain_name
  tags = {
    Name = "${var.env}-${var.project}-hostzone"
  }
}

# # -----------------------------
# # Cert validation
# # -----------------------------
# resource "aws_route53_record" "main" {
#   for_each = {
#     for dvo in aws_acm_certificate.main.domain_validation_options : dvo.domain_name => {
#       name   = dvo.resource_record_name
#       record = dvo.resource_record_value
#       type   = dvo.resource_record_type   
#     }
#   }
#   allow_overwrite = true
#   name            = each.value.name
#   records         = [each.value.record]
#   ttl             = 60
#   type            = each.value.type
#   zone_id         = aws_route53_zone.main.id
# }

# # -----------------------------
# # SES
# # -----------------------------

# # For SES
# resource "aws_route53_record" "ses_txt" {
#   zone_id = aws_route53_zone.main.zone_id
#   name    = "_amazonses.${var.domain_name}"
#   type    = "TXT"
#   ttl     = "600"
#   records = [aws_ses_domain_identity.main.verification_token]
# }

# # For DKIM
# resource "aws_route53_record" "ses_dkim" {
#   count   = 3
#   zone_id = aws_route53_zone.main.zone_id
#   name    = "${element(aws_ses_domain_dkim.main.dkim_tokens, count.index)}._domainkey.${var.domain_name}"
#   type    = "CNAME"
#   ttl     = "600"
#   records = ["${element(aws_ses_domain_dkim.main.dkim_tokens, count.index)}.dkim.amazonses.com"]
# }

# # For SPF
# resource "aws_route53_record" "ses_spf_mx" {
#   zone_id = aws_route53_zone.main.zone_id
#   name    = aws_ses_domain_mail_from.main.mail_from_domain
#   type    = "MX"
#   ttl     = "600"
#   records = ["10 feedback-smtp.ap-northeast-1.amazonses.com"]
# }

# resource "aws_route53_record" "ses_spf_txt" {
#   zone_id = aws_route53_zone.main.zone_id
#   name    = aws_ses_domain_mail_from.main.mail_from_domain
#   type    = "TXT"
#   ttl     = "600"
#   records = ["v=spf1 include:amazonses.com ~all"]
# }

# # For DMARC
# resource "aws_route53_record" "ses_dmarc" {
#   zone_id = aws_route53_zone.main.zone_id
#   name    = "_dmarc.${var.domain_name}"
#   type    = "TXT"
#   ttl     = "600"
#   records = ["v=DMARC1;p=quarantine;pct=25;rua=mailto:dmarcreports@${var.domain_name}"]
# }

# # -----------------------------
# # CloudFront 
# # -----------------------------
# resource "aws_route53_record" "cloudfront" {
#   zone_id = aws_route53_zone.main.zone_id
#   name    = var.domain_name
#   type    = "A"

#   alias {
#     name                   = aws_cloudfront_distribution.distribution.domain_name
#     zone_id                = aws_cloudfront_distribution.distribution.hosted_zone_id
#     evaluate_target_health = false
#   }
# }

# # www サブドメイン用のレコード
# resource "aws_route53_record" "cloudfront_www" {
#   zone_id = aws_route53_zone.main.zone_id
#   name    = "www.${var.domain_name}"
#   type    = "A"

#   alias {
#     name                   = aws_cloudfront_distribution.distribution.domain_name
#     zone_id                = aws_cloudfront_distribution.distribution.hosted_zone_id
#     evaluate_target_health = false
#   }
# }

