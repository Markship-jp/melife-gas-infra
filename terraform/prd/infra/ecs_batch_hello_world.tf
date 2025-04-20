locals {
  hello_world_task_definition_name = "${var.env}-${var.project}-hello-world-ecs-definition"
  hello_world_container_name      = "${var.env}-${var.project}-hello-world-ecs-container"
}

# 動作確認用バッチECS Task Definition
resource "aws_ecs_task_definition" "hello_world" {
  family                   = local.hello_world_task_definition_name
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
      name        = local.hello_world_container_name
      image       = local.batch_container_image_uri
      essential   = true
      entrypoint  = ["/usr/local/bin/node"]
      command     = ["./dist/services/src/cli.js", "hello-worlds"]
      secrets     = local.batch_container_secrets
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.batch_ecs.name
          "awslogs-region"        = data.aws_region.current.name
          "awslogs-stream-prefix" = "hello-world-batch"
        }
      }
    }
  ])
} 