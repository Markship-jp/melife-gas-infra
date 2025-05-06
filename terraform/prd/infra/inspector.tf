locals {
  inspector_eventbridge_rule_name = "${var.env}-${var.project}-rule-inspector"
}

# AWS Inspectorを有効化
resource "aws_inspector2_enabler" "main" {
  account_ids    = [data.aws_caller_identity.current.account_id]
  resource_types = ["ECR"]
}

# EventBridgeルール - InspectorのCritical以上の脆弱性を検出
resource "aws_cloudwatch_event_rule" "vulnerability" {
  name        = local.inspector_eventbridge_rule_name
  description = "Capture Inspector results with severity Critical"

  event_pattern = jsonencode({
    source      = ["aws.inspector2"],
    detail-type = ["Inspector2 Finding"],
    detail      = {
      severity  = ["CRITICAL"],
      status    = ["ACTIVE"]
    }
  })
}

#resource "aws_cloudwatch_event_target" "inspector_to_sns" {
#  rule      = aws_cloudwatch_event_rule.vulnerability.name
#  target_id = "InspectorToSNS"
#  arn       = aws_sns_topic.jira_eventbridge.arn
# トランスフォーマーの追加を行う
#}