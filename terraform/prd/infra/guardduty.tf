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

# EventBridgeルールのターゲット設定
resource "aws_cloudwatch_event_target" "threat_findings" {
  rule      = aws_cloudwatch_event_rule.threat_findings.name
  target_id = "SendToSNS"
  arn       = aws_sns_topic.jira_eventbridge.arn

  # 通知内容を見やすく整形するためのトランスフォーマー
  input_transformer {
    input_paths = {
      severity       = "$.detail.severity"
      type           = "$.detail.type"
      title          = "$.detail.title"
      description    = "$.detail.description"
      account_id     = "$.detail.accountId"
      region         = "$.region"
      finding_id     = "$.detail.id"
      resource_type  = "$.detail.resource.resourceType"
      resource_id    = "$.detail.resource.instanceDetails.instanceId"
      finding_time   = "$.detail.service.eventFirstSeen"
      updated_time   = "$.detail.updatedAt"
    }
    
    input_template = <<EOF
      {
        "重要度": <severity>,
        "検出時刻": <finding_time>,
        "更新時刻": <updated_time>,
        "アカウントID": <account_id>,
        "リージョン": <region>,
        "検出ID": <finding_id>,
        "タイトル": <title>,
        "説明": <description>,
        "タイプ": <type>,
        "リソースタイプ": <resource_type>,
        "リソースID": <resource_id>,
        "対応推奨事項": "GuardDuty コンソールで詳細を確認し、適切な対応を取ってください。"
      }
    EOF
  }
}
