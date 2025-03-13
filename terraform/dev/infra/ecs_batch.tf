locals {
  batch_ecs_cluster_name               = "${var.env}-${var.project}-batch-ecs-cluster"
  batch_container_image_uri            = "${aws_ecr_repository.batch.repository_url}:latest"
  batch_task_definition_name           = "${var.env}-${var.project}-batch-ecs-definition"
  batch_cpu                            = 1024
  batch_memory                         = 2048
  batch_container_name                 = "${var.env}-${var.project}-batch-ecs-container"
  batch_ecs_task_role                  = "${var.env}-${var.project}-batch-ecs-task-role"
  batch_execution_role_name            = "${var.env}-${var.project}-batch-ecs-execution-role"
  batch_ecs_task_ssm_policy            = "${var.env}-${var.project}-batch-ecs-task-ssm_policy"
  batch_ecs_transferfamily_policy_name = "${var.env}-${var.project}-batch-ecs-transferfamily-policy"
  batch_parameterstore_arn             = "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/${var.env}/${var.project}/batch"
  batch_eventbridge_role_name          = "${var.env}-${var.project}-batch-eventbridge-role"
  batch_eventbridge_policy_name        = "${var.env}-${var.project}-batch-eventbridge-policy"
}

# バッチ用ECS Cluster
resource "aws_ecs_cluster" "batch" {
  name = local.batch_ecs_cluster_name
}

# バッチ用ECS Task Definition
resource "aws_ecs_task_definition" "batch" {
  family                   = local.batch_task_definition_name
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
      name      = local.batch_container_name
      image     = local.batch_container_image_uri
      essential = true
      secrets = [
       {
          name      = "DATABASE_URL"
          valueFrom = "${local.parameterstore_arn}/DATABASE_URL"
        },
        {
          name      = "AUTH_TOKEN_SECRET"
          valueFrom = "${local.parameterstore_arn}/AUTH_TOKEN_SECRET"
        },
        {
          name      = "FRONTEND_HOST"
          valueFrom = "${local.parameterstore_arn}/FRONTEND_HOST"
        },
        {
          name      = "MAIL_HOST"
          valueFrom = "${local.parameterstore_arn}/MAIL_HOST"
        },
        {
          name      = "MAIL_PORT"
          valueFrom = "${local.parameterstore_arn}/MAIL_PORT"
        },
        {
          name      = "MAIL_USERNAME"
          valueFrom = "${local.parameterstore_arn}/MAIL_USERNAME"
        },
        {
          name      = "MAIL_PASSWORD"
          valueFrom = "${local.parameterstore_arn}/MAIL_PASSWORD"
        },
        {
          name      = "MAIL_FROM_ADDRESS"
          valueFrom = "${local.parameterstore_arn}/MAIL_FROM_ADDRESS"
        },
        {
          name      = "ZIPCODE_APIKEY"
          valueFrom = "${local.parameterstore_arn}/ZIPCODE_APIKEY"
        },
        {
          name      = "PAYGENT_MERCHANT_ID"
          valueFrom = "${local.parameterstore_arn}/PAYGENT_MERCHANT_ID"
        },
        {
          name      = "PAYGENT_MERCHANT_NAME"
          valueFrom = "${local.parameterstore_arn}/PAYGENT_MERCHANT_NAME"
        },
        {
          name      = "PAYGENT_HASH_KEY"
          valueFrom = "${local.parameterstore_arn}/PAYGENT_HASH_KEY"
        },
        {
          name      = "PAYGENT_COMPANY_NAME"
          valueFrom = "${local.parameterstore_arn}/PAYGENT_COMPANY_NAME"
        },
        {
          name      = "PAYGENT_LINK_URL"
          valueFrom = "${local.parameterstore_arn}/PAYGENT_LINK_URL"
        },
        {
          name      = "PAYGENT_CONNECT_ID"
          valueFrom = "${local.parameterstore_arn}/PAYGENT_CONNECT_ID"
        },
        {
          name      = "PAYGENT_CONNECT_PASSWORD"
          valueFrom = "${local.parameterstore_arn}/PAYGENT_CONNECT_PASSWORD"
        },
        {
          name      = "PAYGENT_CONNECT_VERSION"
          valueFrom = "${local.parameterstore_arn}/PAYGENT_CONNECT_VERSION"
        },
        {
          name      = "PAYGENT_PFX_PASSWORD"
          valueFrom = "${local.parameterstore_arn}/PAYGENT_PFX_PASSWORD"
        },
        {
          name      = "PAYGENT_PFX_KEY"
          valueFrom = "${local.parameterstore_arn}/PAYGENT_PFX_KEY"
        },
        {
          name      = "PAYGENT_MODULE_CONNECT_URL"
          valueFrom = "${local.parameterstore_arn}/PAYGENT_MODULE_CONNECT_URL"
        },
        {
          name      = "AWS_DOWNLOAD_BUCKET_NAME"
          valueFrom = "${local.parameterstore_arn}/AWS_DOWNLOAD_BUCKET_NAME"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.batch_ecs.name
          "awslogs-region"        = data.aws_region.current.name
          "awslogs-stream-prefix" = "batch-ecs"
        }
      }
    }
  ])
}

# バッチ用CloudWatch Logs
resource "aws_cloudwatch_log_group" "batch_ecs" {
  name              = "/ecs/${var.env}-${var.project}-batch"
  retention_in_days = 30
}

# バッチ用IAM Role for ECS Task Execution
resource "aws_iam_role" "batch_ecs_task_execution" {
  name = local.batch_execution_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "batch_ecs_task_ssm_policy" {
  name        = local.batch_ecs_task_ssm_policy
  description = "Policy to allow ParameterStore for batch"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParametersByPath"
        ],
        Resource = [
          "${local.parameterstore_arn}/*",
          "${local.batch_parameterstore_arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "batch_ecs_task_execution_policy" {
  role       = aws_iam_role.batch_ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "batch_ecs_task_ssm_policy_attachment" {
  role       = aws_iam_role.batch_ecs_task_execution.name
  policy_arn = aws_iam_policy.batch_ecs_task_ssm_policy.arn
}

# バッチ用IAM Role for ECS Task
resource "aws_iam_role" "batch_ecs_task_role" {
  name = local.batch_ecs_task_role
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "batch_ecs_s3_policy" {
  name = local.batch_ecs_transferfamily_policy_name
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:PutObject"
        ],
        Effect = "Allow",
        Resource = [
          "${aws_s3_bucket.storage.arn}",
          "${aws_s3_bucket.storage.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "batch_ecs_s3_policy_attachment" {
  role       = aws_iam_role.batch_ecs_task_role.name
  policy_arn = aws_iam_policy.batch_ecs_s3_policy.arn
}

resource "aws_iam_role_policy_attachment" "batch_ecs_task_policy" {
  role       = aws_iam_role.batch_ecs_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "batch_ecs_task_ses_policy" {
  role       = aws_iam_role.batch_ecs_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSESFullAccess"
}

# EventBridge IAM Role
resource "aws_iam_role" "batch_eventbridge_role" {
  name = local.batch_eventbridge_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "scheduler.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "batch_eventbridge_policy" {
  name = local.batch_eventbridge_policy_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecs:RunTask"
        ]
        Resource = [
          aws_ecs_task_definition.batch.arn
        ]
        Condition = {
          ArnLike = {
            "ecs:cluster" = aws_ecs_cluster.batch.arn
          }
        }
      },
      {
        Effect = "Allow"
        Action = [
          "iam:PassRole"
        ]
        Resource = [
          aws_iam_role.batch_ecs_task_execution.arn,
          aws_iam_role.batch_ecs_task_role.arn
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "batch_eventbridge_policy_attachment" {
  role       = aws_iam_role.batch_eventbridge_role.name
  policy_arn = aws_iam_policy.batch_eventbridge_policy.arn
}

# EventBridge Scheduler
resource "aws_scheduler_schedule" "batch_daily" {
  name       = "${var.env}-${var.project}-batch-daily"
  group_name = "default"
  flexible_time_window {
    mode = "OFF"
  }
  schedule_expression = "cron(0 0 * * ? *)" # 毎日午前0時（UTC）に実行
  schedule_expression_timezone = "UTC"
  state = "DISABLED"
  target {
    arn      = aws_ecs_cluster.batch.arn
    role_arn = aws_iam_role.batch_eventbridge_role.arn
    ecs_parameters {
      task_definition_arn = aws_ecs_task_definition.batch.arn
      task_count         = 1
      launch_type        = "FARGATE"
      network_configuration {
        subnets         = [aws_subnet.private_app_1a.id, aws_subnet.private_app_1c.id]
        security_groups = [aws_security_group.batch.id]
      }
    }
  }
}