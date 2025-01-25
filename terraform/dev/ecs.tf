locals {
  ecs_cluster_name               = "${var.env}-${var.project}-ecs-cluster"
  container_image_uri            = "${aws_ecr_repository.main.repository_url}:dev-melife-gas-20250601-25"
  task_definition_name           = "${var.env}-${var.project}-ecs-definition"
  cpu                            = 1024
  memory                         = 2048
  container_name                 = "${var.env}-${var.project}-ecs-container"
  ecs_service_name               = "${var.env}-${var.project}-ecs-service"
  desired_count                  = 1
  max_count                      = 1
  min_count                      = 1
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
          name      = "ZIPCODE_APIKEY"
          valueFrom = "${local.parameterstore_arn}/ZIPCODE_APIKEY"
        },
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
}

resource "aws_appautoscaling_policy" "scale_up" {
  name               = "${var.env}-${var.project}-ecs-scale-up"
  resource_id        = aws_appautoscaling_target.ecs.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs.service_namespace
  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 120
    metric_aggregation_type = "Average"
    step_adjustment {
      scaling_adjustment          = 1
      metric_interval_lower_bound = 0
    }
  }
}

resource "aws_appautoscaling_policy" "scale_down" {
  name               = "${var.env}-${var.project}-ecs-scale-down"
  resource_id        = aws_appautoscaling_target.ecs.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs.service_namespace
  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 120
    metric_aggregation_type = "Average"
    step_adjustment {
      scaling_adjustment          = -1
      metric_interval_upper_bound = 0
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "alarm_cpu_high" {
  alarm_name          = "${var.env}-${var.project}-ecs-cpu-utilization-high"
  
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  
  # CPU使用率のしきい値
  threshold           = "90"

  dimensions = {
    ClusterName = aws_ecs_cluster.main.name
    ServiceName = aws_ecs_service.main.name
  }
  
  alarm_actions = [aws_appautoscaling_policy.scale_up.arn]
}

resource "aws_cloudwatch_metric_alarm" "alarm_cpu_low" {
  alarm_name          = "${var.env}-${var.project}-ecs-cpu-utilization-low"
  
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  
  # CPU使用率のしきい値
  threshold           = "30"

  dimensions = {
    ClusterName = aws_ecs_cluster.main.name
    ServiceName = aws_ecs_service.main.name
  }

  alarm_actions = [aws_appautoscaling_policy.scale_down.arn]
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
          "ssmmessages:OpenDataChannel"
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

# resource "aws_iam_policy" "ecs_s3_policy" {
#   name = local.ecs_transferfamily_policy_name
#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Action = [
#           "s3:ListBucket",
#           "s3:GetObject",
#           "s3:DeleteObject",
#           "s3:PutObject"
#         ],
#         Effect = "Allow",
#         Resource = [
#           "${aws_s3_bucket.xxxx.arn}",
#           "${aws_s3_bucket.sftp-xxxx.arn}/*"
#         ]
#       }
#     ]
#   })
# }


resource "aws_iam_role_policy_attachment" "ecs_exec_policy_attachment" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.ecs_exec_policy.arn
}

# resource "aws_iam_role_policy_attachment" "ecs_s3_policy_attachment" {
#   role       = aws_iam_role.ecs_task_role.name
#   policy_arn = aws_iam_policy.ecs_s3_policy.arn
# }


resource "aws_iam_role_policy_attachment" "ecs_task_policy" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecs_task_ses_policy" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSESFullAccess"
}




