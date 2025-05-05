locals {
  guardduty_eventbridge_rule_name= "${var.env}-${var.project}-rule-guardduty"
}

# GuardDutyの設定はCloudFormationで管理
resource "aws_cloudformation_stack" "guardduty" {
  name = "guardduty-stack"
  template_body = file("${path.module}/template/guardduty.yaml")
  capabilities = ["CAPABILITY_IAM"]
}

# EventBridgeルール
resource "aws_cloudwatch_event_rule" "threat_findings" {
  name        = local.guardduty_eventbridge_rule_name
  description = "Capture GuardDuty findings with severity Medium or higher"

  event_pattern = jsonencode({
    source      = ["aws.guardduty"]
    detail-type = ["GuardDuty Finding"]
    detail = {
      severity = [
        {
          numeric = [">=", 4.0] # Medium以上 (4.0-6.9: Medium, 7.0-8.9: High, 9.0+: Critical)
        }
      ]
    }
  })
}