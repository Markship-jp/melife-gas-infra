# SES
resource "aws_ses_domain_identity" "main" {
  domain = var.domain_name
}

## For DKIM
resource "aws_ses_domain_dkim" "main" {
  domain = var.domain_name

  depends_on = [
    aws_ses_domain_identity.main
  ]
}

## For SPF
resource "aws_ses_domain_mail_from" "main" {
  domain           = var.domain_name
  mail_from_domain = "mail.${var.domain_name}"

  depends_on = [
    aws_ses_domain_identity.main
  ]
}