# GuardDutyの設定はCloudFormationで管理
resource "aws_cloudformation_stack" "guardduty" {
  name = "guardduty-stack"
  template_body = file("${path.module}/template/guardduty.yaml")
  capabilities = ["CAPABILITY_IAM"]
}
