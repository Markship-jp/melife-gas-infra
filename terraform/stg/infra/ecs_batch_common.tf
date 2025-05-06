locals {
  batch_ecs_cluster_name               = "${var.env}-${var.project}-batch-ecs-cluster"
  batch_container_image_uri            = "${aws_ecr_repository.batch.repository_url}:latest"
  batch_cpu                            = 1024
  batch_memory                         = 2048
  batch_ecs_task_role                  = "${var.env}-${var.project}-batch-ecs-task-role"
  batch_execution_role_name            = "${var.env}-${var.project}-batch-ecs-execution-role"
  batch_ecs_task_ssm_policy            = "${var.env}-${var.project}-batch-ecs-task-ssm_policy"
  batch_ecs_transferfamily_policy_name = "${var.env}-${var.project}-batch-ecs-transferfamily-policy"
  batch_parameterstore_arn             = "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/${var.env}/${var.project}"
  batch_eventbridge_role_name          = "${var.env}-${var.project}-batch-eventbridge-role"
  batch_eventbridge_policy_name        = "${var.env}-${var.project}-batch-eventbridge-policy"
  
  # バッチコンテナ共通の環境変数
  batch_container_secrets = [
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
}

# バッチ用ECS Cluster
resource "aws_ecs_cluster" "batch" {
  name = local.batch_ecs_cluster_name
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
          "*"
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