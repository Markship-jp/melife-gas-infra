locals {
  ecs_cluster_name               = "${var.env}-${var.project}-ecs-cluster"
  container_image_uri            = "${aws_ecr_repository.main.repository_url}:latest"
  task_definition_name           = "${var.env}-${var.project}-ecs-definition"
  migration_task_definition_name = "${var.env}-${var.project}-migration-definition"
  cpu                            = 1024
  memory                         = 2048
  container_name                 = "${var.env}-${var.project}-ecs-container"
  migration_container_name       = "${var.env}-${var.project}-migration-container"
  ecs_service_name               = "${var.env}-${var.project}-ecs-service"
  desired_count                  = 2
  max_count                      = 4
  min_count                      = 2
  ecs_task_role                  = "${var.env}-${var.project}-ecs-task-role"
  execution_role_name            = "${var.env}-${var.project}-ecs-execution-role"
  ecs_task_ssm_policy            = "${var.env}-${var.project}-ecs-task-ssm_policy"
  ecs_exec_policy                = "${var.env}-${var.project}-ecs-exec-policy"
  ecs_transferfamily_policy_name = "${var.env}-${var.project}-ecs-transferfamily-policy"
  parameterstore_arn             = "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/${var.env}/${var.project}"
}


# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = local.ecs_cluster_name
}

# ECS Task Definition
resource "aws_ecs_task_definition" "main" {
  family                   = local.task_definition_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = local.cpu
  memory                   = local.memory
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  skip_destroy             = true
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }
  container_definitions = jsonencode([
    {
      name      = local.container_name
      image     = local.container_image_uri
      essential = true
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
        }
      ]
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
          name      = "ZIPCODE_API_KEY"
          valueFrom = "${local.parameterstore_arn}/ZIPCODE_API_KEY"
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
        },
        {
          name      = "KUMO_ORDER_SYSTEM_ENDPOINT"
          valueFrom = "${local.parameterstore_arn}/KUMO_ORDER_SYSTEM_ENDPOINT"
        },
        {
          name      = "KUMO_SYSTEM_ENDPOINT"
          valueFrom = "${local.parameterstore_arn}/KUMO_SYSTEM_ENDPOINT"
        },
        {
          name      = "KUMO_ORDER_SYSTEM_USERNAME"
          valueFrom = "${local.parameterstore_arn}/KUMO_ORDER_SYSTEM_USERNAME"
        },
        {
          name      = "KUMO_COMPANY_ID"
          valueFrom = "${local.parameterstore_arn}/KUMO_COMPANY_ID"
        },
        {
          name      = "KUMO_TENANT_ID"
          valueFrom = "${local.parameterstore_arn}/KUMO_TENANT_ID"
        },
        {
          name      = "TODEN_PRICE_PLAN_ID"
          valueFrom = "${local.parameterstore_arn}/TODEN_PRICE_PLAN_ID"
        },
        {
          name      = "CHUDEN_PRICE_PLAN_ID"
          valueFrom = "${local.parameterstore_arn}/CHUDEN_PRICE_PLAN_ID"
        },
        {
          name      = "KANSAI_PRICE_PLAN_ID"
          valueFrom = "${local.parameterstore_arn}/KANSAI_PRICE_PLAN_ID"
        },
        {
          name      = "SAIBU_PRICE_PLAN_ID"
          valueFrom = "${local.parameterstore_arn}/SAIBU_PRICE_PLAN_ID"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs.name
          "awslogs-region"        = data.aws_region.current.name
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  # 初期構築のみterraformで行う
  lifecycle {
    ignore_changes = [
      container_definitions
    ]
  }
}

# ECS Service
resource "aws_ecs_service" "main" {
  name                   = local.ecs_service_name
  cluster                = aws_ecs_cluster.main.id
  task_definition        = aws_ecs_task_definition.main.arn
  desired_count          = local.desired_count
  launch_type            = "FARGATE"
  enable_execute_command = true
  network_configuration {
    subnets         = [aws_subnet.private_app_1a.id, aws_subnet.private_app_1c.id]
    security_groups = [aws_security_group.ecs.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.main.arn
    container_name   = local.container_name
    container_port   = 3000
  }

  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200

  lifecycle {
    ignore_changes = [task_definition]
  }
}

# Auto Scaling
resource "aws_appautoscaling_target" "ecs" {
  max_capacity       = local.max_count
  min_capacity       = local.min_count
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.main.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  lifecycle {
    ignore_changes = [
      min_capacity,
      max_capacity,
    ]
  }  
}

resource "aws_appautoscaling_policy" "ecs" {
  name               = "${var.env}-${var.project}-ecs-autoscaling"
  resource_id        = aws_appautoscaling_target.ecs.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs.service_namespace
  policy_type = "TargetTrackingScaling"
  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value = 70
    scale_in_cooldown = 180
    scale_out_cooldown = 180
    disable_scale_in = false
  }
  lifecycle {
    ignore_changes = [
      target_tracking_scaling_policy_configuration[0].target_value
    ]
  }
}

# Create IAM Role for ECS Task Execution
resource "aws_iam_role" "ecs_task_execution" {
  name = local.execution_role_name

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

resource "aws_iam_policy" "ecs_task_ssm_policy" {
  name        = local.ecs_task_ssm_policy
  description = "Policy to allow ParameterStore"
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
          "${local.parameterstore_arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecs_task_ssm_policy_attachment" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = aws_iam_policy.ecs_task_ssm_policy.arn
}

# Create IAM Role for ECS Task 
resource "aws_iam_policy" "ecs_exec_policy" {
  name        = local.ecs_exec_policy
  description = "Policy to allow ECS Exec"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ssm:DescribeSessions",
          "ssm:GetConnectionStatus",
          "ssm:StartSession",
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel",
          "logs:DescribeLogStreams",
          "logs:DescribeLogGroups",
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "ecs_task_role" {
  name = local.ecs_task_role
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

resource "aws_iam_policy" "ecs_s3_policy" {
  name = local.ecs_transferfamily_policy_name
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


resource "aws_iam_role_policy_attachment" "ecs_exec_policy_attachment" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.ecs_exec_policy.arn
}

resource "aws_iam_role_policy_attachment" "ecs_s3_policy_attachment" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.ecs_s3_policy.arn
}


resource "aws_iam_role_policy_attachment" "ecs_task_policy" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecs_task_ses_policy" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSESFullAccess"
}

# マイグレーション用 ECS Task Definition
resource "aws_ecs_task_definition" "migration" {
  family                   = local.migration_task_definition_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = local.cpu
  memory                   = local.memory
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  skip_destroy             = true
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }
  container_definitions = jsonencode([
    {
      name       = local.migration_container_name
      image      = local.container_image_uri
      essential  = true
      entryPoint = ["node_modules/.bin/prisma"]
      command    = ["migrate", "deploy", "--schema", "./services/prisma/schema.prisma"]
      secrets = [
        {
          name      = "DATABASE_URL"
          valueFrom = "${local.batch_parameterstore_arn}/DATABASE_URL"
        },
        {
          name      = "AUTH_TOKEN_SECRET"
          valueFrom = "${local.batch_parameterstore_arn}/AUTH_TOKEN_SECRET"
        },
        {
          name      = "FRONTEND_HOST"
          valueFrom = "${local.batch_parameterstore_arn}/FRONTEND_HOST"
        },
        {
          name      = "MAIL_HOST"
          valueFrom = "${local.batch_parameterstore_arn}/MAIL_HOST"
        },
        {
          name      = "MAIL_PORT"
          valueFrom = "${local.batch_parameterstore_arn}/MAIL_PORT"
        },
        {
          name      = "MAIL_USERNAME"
          valueFrom = "${local.batch_parameterstore_arn}/MAIL_USERNAME"
        },
        {
          name      = "MAIL_PASSWORD"
          valueFrom = "${local.batch_parameterstore_arn}/MAIL_PASSWORD"
        },
        {
          name      = "MAIL_FROM_ADDRESS"
          valueFrom = "${local.batch_parameterstore_arn}/MAIL_FROM_ADDRESS"
        },
        {
          name      = "ZIPCODE_API_KEY"
          valueFrom = "${local.batch_parameterstore_arn}/ZIPCODE_API_KEY"
        },
        {
          name      = "PAYGENT_MERCHANT_ID"
          valueFrom = "${local.batch_parameterstore_arn}/PAYGENT_MERCHANT_ID"
        },
        {
          name      = "PAYGENT_MERCHANT_NAME"
          valueFrom = "${local.batch_parameterstore_arn}/PAYGENT_MERCHANT_NAME"
        },
        {
          name      = "PAYGENT_HASH_KEY"
          valueFrom = "${local.batch_parameterstore_arn}/PAYGENT_HASH_KEY"
        },
        {
          name      = "PAYGENT_COMPANY_NAME"
          valueFrom = "${local.batch_parameterstore_arn}/PAYGENT_COMPANY_NAME"
        },
        {
          name      = "PAYGENT_LINK_URL"
          valueFrom = "${local.batch_parameterstore_arn}/PAYGENT_LINK_URL"
        },
        {
          name      = "PAYGENT_CONNECT_ID"
          valueFrom = "${local.batch_parameterstore_arn}/PAYGENT_CONNECT_ID"
        },
        {
          name      = "PAYGENT_CONNECT_PASSWORD"
          valueFrom = "${local.batch_parameterstore_arn}/PAYGENT_CONNECT_PASSWORD"
        },
        {
          name      = "PAYGENT_CONNECT_VERSION"
          valueFrom = "${local.batch_parameterstore_arn}/PAYGENT_CONNECT_VERSION"
        },
        {
          name      = "PAYGENT_PFX_PASSWORD"
          valueFrom = "${local.batch_parameterstore_arn}/PAYGENT_PFX_PASSWORD"
        },
        {
          name      = "PAYGENT_PFX_KEY"
          valueFrom = "${local.batch_parameterstore_arn}/PAYGENT_PFX_KEY"
        },
        {
          name      = "PAYGENT_MODULE_CONNECT_URL"
          valueFrom = "${local.batch_parameterstore_arn}/PAYGENT_MODULE_CONNECT_URL"
        },
        {
          name      = "AWS_DOWNLOAD_BUCKET_NAME"
          valueFrom = "${local.batch_parameterstore_arn}/AWS_DOWNLOAD_BUCKET_NAME"
        },
        {
          name      = "KUMO_ORDER_SYSTEM_ENDPOINT"
          valueFrom = "${local.batch_parameterstore_arn}/KUMO_ORDER_SYSTEM_ENDPOINT"
        },
        {
          name      = "KUMO_SYSTEM_ENDPOINT"
          valueFrom = "${local.batch_parameterstore_arn}/KUMO_SYSTEM_ENDPOINT"
        },
        {
          name      = "KUMO_ORDER_SYSTEM_USERNAME"
          valueFrom = "${local.batch_parameterstore_arn}/KUMO_ORDER_SYSTEM_USERNAME"
        },
        {
          name      = "KUMO_COMPANY_ID"
          valueFrom = "${local.batch_parameterstore_arn}/KUMO_COMPANY_ID"
        },
        {
          name      = "KUMO_TENANT_ID"
          valueFrom = "${local.batch_parameterstore_arn}/KUMO_TENANT_ID"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs.name
          "awslogs-region"        = data.aws_region.current.name
          "awslogs-stream-prefix" = "ecs-migration"
        }
      }
    }
  ])
}

# Output for migration task definition
output "migration_task_definition" {
  value = aws_ecs_task_definition.migration.family
}

output "ecs_security_group_id" {
  value = aws_security_group.ecs.id
}

output "private_subnet_ids" {
  value = "${aws_subnet.private_app_1a.id},${aws_subnet.private_app_1c.id}"
}




