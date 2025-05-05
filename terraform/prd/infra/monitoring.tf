locals {
  log_monitoring = {
    "[Log]ECS Error" = {
      filter    = "qRdvymPpIAC7sCfxAGOG"
      log_group = aws_cloudwatch_log_group.ecs.name
      # log_group = "/aws/ecs/prd-melife-gas"
    }
  }
}

# -----------------------------
# Policy
# -----------------------------
# Budgetsへの許可
resource "aws_sns_topic_policy" "jira_sns_policy" {
  arn = aws_sns_topic.jira_cloudwatch.arn
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "budgets.amazonaws.com"
        },
        Action   = "sns:Publish",
        Resource = aws_sns_topic.jira_cloudwatch.arn
      }
    ]
  })
}

resource "aws_iam_role" "cloudwatch_logs_role" {
  name = "cloudwatch_logs_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "logs.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "cloudwatch_logs_policy" {
  name = "cloudwatch_logs_policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:PutSubscriptionFilter"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cloudwatch_logs_role_attachment" {
  role       = aws_iam_role.cloudwatch_logs_role.name
  policy_arn = aws_iam_policy.cloudwatch_logs_policy.arn
}

# -----------------------------
# SNS 
# -----------------------------
# JIRA連携用のSNSトピック(Cloudwatch連携)
resource "aws_sns_topic" "jira_cloudwatch" {
  name = "jira_service_management_cloudwatch"
}

# JIRA連携用のSNSトピック(SNS連携)
#resource "aws_sns_topic" "jira_sns" {
#  name = "jira_service_management_sns"
#}

resource "aws_sns_topic_subscription" "jira_subscription_cloudwatch" {
  topic_arn = aws_sns_topic.jira_cloudwatch.arn
  protocol  = "https"
  endpoint  = var.jira_endpoint_cloudwatch
}

#resource "aws_sns_topic_subscription" "jira_subscription_sns" {
#  topic_arn = aws_sns_topic.jira_sns.arn
#  protocol  = "https"
#  endpoint  = data.aws_ssm_parameter.jira_sns.value
#}

# -----------------------------
# Cloudwatch 
# -----------------------------
# ECS
# CPU使用率
resource "aws_cloudwatch_metric_alarm" "ecs_cpu" {
  alarm_name          = "[ECS]CPU Utilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 5
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = 90
  alarm_description   = "This metric monitors CPU usage"
  alarm_actions       = [aws_sns_topic.jira_cloudwatch.arn]
  dimensions = {
    ClusterName = aws_ecs_cluster.main.name
    ServiceName = aws_ecs_service.main.name
  }
}

# メモリ使用率
resource "aws_cloudwatch_metric_alarm" "ecs_memory" {
  alarm_name          = "[ECS]Memory Utilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 5
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = 90
  alarm_description   = "This metric monitors Memory usage"
  alarm_actions       = [aws_sns_topic.jira_cloudwatch.arn]
  dimensions = {
    ClusterName = aws_ecs_cluster.main.name
    ServiceName = aws_ecs_service.main.name
  }
}

# RDS
resource "aws_cloudwatch_metric_alarm" "rds_cpu" {
  alarm_name          = "[RDS]CPU Utilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 5
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Average"
  threshold           = 90
  alarm_description   = "This metric monitors CPU usage"
  alarm_actions       = [aws_sns_topic.jira_cloudwatch.arn]
  dimensions = {
    DBClusterIdentifier = aws_rds_cluster.aurora_cluster.cluster_identifier
  }
}

# CloudFront
# 5XXエラー
#resource "aws_cloudwatch_metric_alarm" "cdn_5xxErrorRate" {
#  alarm_name          = "[CloudFront]5XXError"
#  comparison_operator = "GreaterThanOrEqualToThreshold"
#  evaluation_periods  = 5
#  metric_name         = "5xxErrorRate"
#  namespace           = "AWS/CloudFront"
#  period              = "60"
#  statistic           = "Average"
#  threshold           = 10
#  alarm_description   = "This metric monitors 5xxErrorRate for CloudFront"
#  alarm_actions       = [aws_sns_topic.jira_cloudwatch.arn]
#  dimensions = {
#    DistributionId = aws_cloudfront_distribution.distribution.id
#    Region = "Global"
#  }
#}

# ALB
# 5XXエラー
resource "aws_cloudwatch_metric_alarm" "lb_5xxError" {
  alarm_name          = "[ALB]HTTPCode_Target_5XX_Count"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 5
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Sum"
  threshold           = 30
  alarm_description   = "This metric monitors 5xxErrorCount for ALB"
  alarm_actions       = [aws_sns_topic.jira_cloudwatch.arn]
  dimensions = {
    LoadBalancer = aws_lb.main.arn_suffix
    TargetGroup  = aws_lb_target_group.main.arn_suffix
  }
}

# レイテンシー
resource "aws_cloudwatch_metric_alarm" "lb_TargetResponseTime" {
  alarm_name          = "[ALB]TargetResponseTime"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 5
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Average"
  threshold           = 10
  alarm_description   = "This metric monitors response time for ALB Target group"
  alarm_actions       = [aws_sns_topic.jira_cloudwatch.arn]
  dimensions = {
    LoadBalancer = aws_lb.main.arn_suffix
    TargetGroup  = aws_lb_target_group.main.arn_suffix
  }
}

# ヘルスチェック失敗
resource "aws_cloudwatch_metric_alarm" "lb_UnHealthyHostCount" {
  alarm_name          = "[ALB]UnHealthyHostCount"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 5
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "This metric monitors unhealty condition for ALB Target group"
  alarm_actions       = [aws_sns_topic.jira_cloudwatch.arn]
  dimensions = {
    LoadBalancer = aws_lb.main.arn_suffix
    TargetGroup  = aws_lb_target_group.main.arn_suffix
  }
}

# -----------------------------
# Budgets
# -----------------------------
# アカウント予算
resource "aws_budgets_budget" "account" {
  name         = "budget-account"
  budget_type  = "COST"
  limit_amount = "500"
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  notification {
    comparison_operator       = "GREATER_THAN"
    threshold                 = 100
    threshold_type            = "PERCENTAGE"
    notification_type         = "FORECASTED"
    subscriber_sns_topic_arns = [aws_sns_topic.jira_cloudwatch.arn]
  }
}

# -----------------------------
# Cloudwatch Logs
# -----------------------------
resource "aws_cloudwatch_log_metric_filter" "error" {
  for_each = local.log_monitoring

  name           = "${each.key}/error"
  pattern        = each.value.filter
  log_group_name = each.value.log_group

  metric_transformation {
    name      = "${each.value.log_group}/error"
    namespace = "alarm/error"
    value     = 1
    unit      = "Count"
  }
}

resource "aws_cloudwatch_metric_alarm" "log" {
  for_each = local.log_monitoring

  alarm_name          = "${each.key}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "${each.value.log_group}/error"
  namespace           = "alarm/error"
  period              = "120"
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "This metric monitors error occurence for ECS application"

  insufficient_data_actions = []

  alarm_actions = [aws_sns_topic.jira_cloudwatch.arn]
}