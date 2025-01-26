# AWSマネージドな証明書の作成
resource "aws_acm_certificate" "main" {
  # ドメイン情報
  domain_name               = "${var.domain_name}"
#  subject_alternative_names = ["*.${var.domain_name}"]
  # 検証方法
  validation_method         = "DNS"
  # キーアルゴリズムの指定
  key_algorithm         = "RSA_2048"
  # タグ設定
  tags = {
    Name = "${var.domain_name}"
  }
}

resource "aws_acm_certificate_validation" "main" {
  certificate_arn = aws_acm_certificate.main.arn
  validation_record_fqdns = [for record in aws_route53_record.main : record.fqdn]  
}