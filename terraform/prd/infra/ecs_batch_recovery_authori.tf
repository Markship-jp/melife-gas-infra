locals {
  recovery_authori_task_definition_name = "${var.env}-${var.project}-recovery-authori-ecs-definition"
  recovery_authori_container_name       = "${var.env}-${var.project}-recovery-authori-ecs-container"
}

# 決済オーソリリカバリーバッチECS Task Definition
resource "aws_ecs_task_definition" "recovery_authori" {
  family                   = local.recovery_authori_task_definition_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = local.batch_cpu
  memory                   = local.batch_memory
  execution_role_arn       = aws_iam_role.batch_ecs_task_execution.arn
  task_role_arn            = aws_iam_role.batch_ecs_task_role.arn
  skip_destroy             = true
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }
  container_definitions = jsonencode([
    {
      name        = local.recovery_authori_container_name
      image       = local.batch_container_image_uri
      essential   = true
      entrypoint  = ["/usr/local/bin/node"]
      command     = ["./dist/services/src/cli.js", "exec-recovery-authori"]
      secrets     = local.batch_container_secrets
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.batch_ecs.name
          "awslogs-region"        = data.aws_region.current.name
          "awslogs-stream-prefix" = "recovery-authori-batch"
        }
      }
    }
  ])
}

# 決済オーソリリカバリーバッチ スケジューラー
resource "aws_scheduler_schedule" "recovery_authori_monthly" {
  name       = "${var.env}-${var.project}-recovery-authori-monthly"
  group_name = "default"
  flexible_time_window {
    mode = "OFF"
  }
  schedule_expression = "cron(0 2 28 * ? *)" # 毎月28日11時00分（日本時間）に実行
  schedule_expression_timezone = "Asia/Tokyo"
  state = "ENABLED"
  target {
    arn      = aws_ecs_cluster.batch.arn
    role_arn = aws_iam_role.batch_eventbridge_role.arn
    ecs_parameters {
      task_definition_arn = aws_ecs_task_definition.recovery_authori.arn
      task_count         = 1
      launch_type        = "FARGATE"
      network_configuration {
        subnets         = [aws_subnet.private_app_1a.id, aws_subnet.private_app_1c.id]
        security_groups = [aws_security_group.batch.id]
      }
    }
  }
}