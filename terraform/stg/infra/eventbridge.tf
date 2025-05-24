locals {
  rds_schedule_target = {
    (aws_rds_cluster.aurora_cluster.cluster_identifier) = {
      start_schedule = "cron(0 9 ? * MON-FRI *)" # 起動スケジュール式（月〜金の9時）
      stop_schedule  = "cron(0 21 * * ? *)"      # 停止スケジュール式（毎日21時）
    }
  }
  
  ecs_schedule_target = {
    (aws_ecs_service.main.name) = {
      start_schedule      = "cron(0 9 ? * MON-FRI *)" # 起動スケジュール式（月〜金の9時）
      stop_schedule       = "cron(0 21 * * ? *)"      # 停止スケジュール式（毎日21時）
      start_desired_count = 1                         # 起動時のdesired_count
      stop_desired_count  = 0                         # 停止時のdesired_count
    }
  }
}

# ==============================
# = RDS Auto Scheduler
# ==============================

# スケジュールに基づいてRDSクラスターを起動する設定
resource "aws_scheduler_schedule" "rds-start" {
  state       = "ENABLED"                                   # 有効化/無効化
  for_each    = local.rds_schedule_target                    # 起動スケジュールのターゲット情報
  name        = "${each.key}-scheduled-start"                # スケジュールの名前
  description = "Scheduled start action for RDS ${each.key}" # スケジュールの説明
  group_name  = "default"                                    # スケジュールのグループ名

  flexible_time_window {
    mode = "OFF" # フレックスタイムウィンドウは使用しない
  }

  schedule_expression          = each.value.start_schedule # 起動するスケジュールの式
  schedule_expression_timezone = "Asia/Tokyo" # タイムゾーンの指定

  # スケジュールのターゲット情報
  target {
    arn      = "arn:aws:scheduler:::aws-sdk:rds:startDBCluster" # RDSのクラスターを起動する操作のARN
    role_arn = aws_iam_role.aurora_scheduler_role.arn           # スケジュール操作のIAMロールのARN

    input = jsonencode({
      DbClusterIdentifier = "${each.key}" # 起動するクラスターの識別子
    })

    # リトライポリシーの設定
    retry_policy {
      maximum_event_age_in_seconds = 600 # リトライする最大のイベントの経過時間：10分
      maximum_retry_attempts       = 10  # リトライの最大回数
    }
  }
}

# スケジュールに基づいてRDSクラスターを停止する設定
resource "aws_scheduler_schedule" "rds-stop" {
  state       = "ENABLED"                                   # 有効化/無効化
  for_each    = local.rds_schedule_target                   # 停止スケジュールのターゲット情報
  name        = "${each.key}-scheduled-stop"                # スケジュールの名前
  description = "Scheduled stop action for RDS ${each.key}" # スケジュールの説明
  group_name  = "default"                                   # スケジュールのグループ名

  flexible_time_window {
    mode = "OFF" # フレックスタイムウィンドウは使用しない
  }

  schedule_expression          = each.value.stop_schedule # 停止するスケジュールのcron式
  schedule_expression_timezone = "Asia/Tokyo" # タイムゾーンの指定

  # スケジュールのターゲット情報
  target {
    arn      = "arn:aws:scheduler:::aws-sdk:rds:stopDBCluster" # RDSのクラスターを停止する操作のARN
    role_arn = aws_iam_role.aurora_scheduler_role.arn          # スケジュール操作のIAMロールのARN

    input = jsonencode({
      DbClusterIdentifier = "${each.key}" # 停止するクラスターの識別子
    })

    # リトライポリシーの設定
    retry_policy {
      maximum_event_age_in_seconds = 600 # リトライする最大のイベントの経過時間：10分
      maximum_retry_attempts       = 10  # リトライの最大回数
    }
  }
}

# ==============================
# = ECS Auto Scheduler
# ==============================

# スケジュールに基づいてECSサービスを起動する設定
resource "aws_scheduler_schedule" "ecs-start" {
  state       = "ENABLED"                                   # 有効化/無効化
  for_each    = local.ecs_schedule_target                    # 起動スケジュールのターゲット情報
  name        = "${each.key}-scheduled-start"                # スケジュールの名前
  description = "Scheduled start action for ECS ${each.key}" # スケジュールの説明
  group_name  = "default"                                    # スケジュールのグループ名

  flexible_time_window {
    mode = "OFF" # フレックスタイムウィンドウは使用しない
  }

  schedule_expression          = each.value.start_schedule # 起動するスケジュールの式
  schedule_expression_timezone = "Asia/Tokyo" # タイムゾーンの指定

  # スケジュールのターゲット情報
  target {
    arn      = "arn:aws:scheduler:::aws-sdk:ecs:updateService" # ECSサービスを更新する操作のARN
    role_arn = aws_iam_role.aurora_scheduler_role.arn          # スケジュール操作のIAMロールのARN

    input = jsonencode({
      Cluster      = aws_ecs_cluster.main.name          # クラスター名
      Service      = "${each.key}"                      # サービス名
      DesiredCount = each.value.start_desired_count     # 起動時のタスク数
    })

    # リトライポリシーの設定
    retry_policy {
      maximum_event_age_in_seconds = 600 # リトライする最大のイベントの経過時間：10分
      maximum_retry_attempts       = 10  # リトライの最大回数
    }
  }
}

# スケジュールに基づいてECSサービスを停止する設定
resource "aws_scheduler_schedule" "ecs-stop" {
  state       = "ENABLED"                                   # 有効化/無効化
  for_each    = local.ecs_schedule_target                    # 停止スケジュールのターゲット情報
  name        = "${each.key}-scheduled-stop"                 # スケジュールの名前
  description = "Scheduled stop action for ECS ${each.key}"  # スケジュールの説明
  group_name  = "default"                                    # スケジュールのグループ名

  flexible_time_window {
    mode = "OFF" # フレックスタイムウィンドウは使用しない
  }

  schedule_expression          = each.value.stop_schedule # 停止するスケジュールの式
  schedule_expression_timezone = "Asia/Tokyo" # タイムゾーンの指定

  # スケジュールのターゲット情報
  target {
    arn      = "arn:aws:scheduler:::aws-sdk:ecs:updateService" # ECSサービスを更新する操作のARN
    role_arn = aws_iam_role.aurora_scheduler_role.arn          # スケジュール操作のIAMロールのARN

    input = jsonencode({
      Cluster      = aws_ecs_cluster.main.name          # クラスター名
      Service      = "${each.key}"                      # サービス名
      DesiredCount = each.value.stop_desired_count     # 停止時のタスク数（0）
    })

    # リトライポリシーの設定
    retry_policy {
      maximum_event_age_in_seconds = 600 # リトライする最大のイベントの経過時間：10分
      maximum_retry_attempts       = 10  # リトライの最大回数
    }
  }
}

# ==============================
# = IAM
# ==============================
resource "aws_iam_role" "aurora_scheduler_role" {
  name = "scheduler-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "scheduler.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "aurora_scheduler_policy" {
  name        = "scheduler-policy"
  description = "Allows Scheduler to start and stop RDS clusters and ECS services"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "rds:StartDBCluster",
          "rds:StopDBCluster"
        ],
        Resource = "arn:aws:rds:*:*:cluster:*"
      },
      {
        Effect = "Allow",
        Action = [
          "ecs:UpdateService",
          "ecs:DescribeServices"
        ],
        Resource = "arn:aws:ecs:*:*:service/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "aurora_scheduler_role_policy" {
  role       = aws_iam_role.aurora_scheduler_role.name
  policy_arn = aws_iam_policy.aurora_scheduler_policy.arn
}
