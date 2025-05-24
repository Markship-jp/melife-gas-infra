# IAM
locals {
  codebuild_build_policy = "${var.env}-${var.project}-codebuild-build-policy"
  codebuild_ecr_policy   = "${var.env}-${var.project}-codebuild-ecr-policy"
  codebuild_project_role = "${var.env}-${var.project}-codebuild-project-role"
  codebuild_batch_project_role = "${var.env}-${var.project}-codebuild-batch-project-role"
  codebuild_batch_build_policy = "${var.env}-${var.project}-codebuild-batch-build-policy"
  codebuild_batch_ecr_policy   = "${var.env}-${var.project}-codebuild-batch-ecr-policy"
  buildprojec_name       = "${var.env}-${var.project}-buildproject"
  batch_buildprojec_name = "${var.env}-${var.project}-batch-buildproject"
  migration_buildprojec_name = "${var.env}-${var.project}-migration-buildproject"
  codebuild_migration_project_role = "${var.env}-${var.project}-codebuild-migration-project-role"
  codebuild_migration_build_policy = "${var.env}-${var.project}-codebuild-migration-build-policy"
}
resource "aws_iam_role" "codebuild_role" {
  name = local.codebuild_project_role
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Principal = { Service = "codebuild.amazonaws.com" },
      Effect    = "Allow"
    }]
  })
}

resource "aws_iam_policy" "codebuild_build_policy" {
  name = local.codebuild_build_policy
  policy = templatefile("./file/codebuild_build_policy.json.tpl", {
    AWS_ACCOUNT_ID    = data.aws_caller_identity.current.account_id
    BUILDPROJECT_NAME = "${aws_codebuild_project.app.name}"
    S3_BUCKET_ARN    = aws_s3_bucket.pipeline.arn
  })
}

resource "aws_iam_role_policy_attachment" "codebuild_build_policy_attach" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = aws_iam_policy.codebuild_build_policy.arn
}

resource "aws_iam_policy" "codebuild_ecr_policy" {
  name = local.codebuild_ecr_policy
  policy = templatefile("./file/codebuild_ecr_policy.json.tpl", {
    AWS_ACCOUNT_ID  = data.aws_caller_identity.current.account_id
    IMAGE_REPO_NAME = var.image_repo_name
  })
}

resource "aws_iam_role_policy_attachment" "codebuild_ecr_policy_attach" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = aws_iam_policy.codebuild_ecr_policy.arn
}

resource "aws_iam_role" "codebuild_batch_role" {
  name = local.codebuild_batch_project_role
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Principal = { Service = "codebuild.amazonaws.com" },
      Effect    = "Allow"
    }]
  })
}

resource "aws_iam_policy" "codebuild_batch_build_policy" {
  name = local.codebuild_batch_build_policy
  policy = templatefile("./file/codebuild_build_policy.json.tpl", {
    AWS_ACCOUNT_ID    = data.aws_caller_identity.current.account_id
    BUILDPROJECT_NAME = "${aws_codebuild_project.batch.name}"
    S3_BUCKET_ARN    = aws_s3_bucket.pipeline.arn
  })
}

resource "aws_iam_role_policy_attachment" "codebuild_batch_build_policy_attach" {
  role       = aws_iam_role.codebuild_batch_role.name
  policy_arn = aws_iam_policy.codebuild_batch_build_policy.arn
}

resource "aws_iam_policy" "codebuild_batch_ecr_policy" {
  name = local.codebuild_batch_ecr_policy
  policy = templatefile("./file/codebuild_ecr_policy.json.tpl", {
    AWS_ACCOUNT_ID  = data.aws_caller_identity.current.account_id
    IMAGE_REPO_NAME = var.batch_image_repo_name
  })
}

resource "aws_iam_role_policy_attachment" "codebuild_batch_ecr_policy_attach" {
  role       = aws_iam_role.codebuild_batch_role.name
  policy_arn = aws_iam_policy.codebuild_batch_ecr_policy.arn
}

# BuildProject
resource "aws_codebuild_project" "app" {
  name         = local.buildprojec_name
  service_role = aws_iam_role.codebuild_role.arn

  source {
    type                = "CODEPIPELINE"
    git_clone_depth     = 0
    insecure_ssl        = false
    report_build_status = false
    buildspec           = file("./file/buildspec.yml")
  }
  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/amazonlinux2-aarch64-standard:3.0-24.06.07"
    type            = "ARM_CONTAINER"
    privileged_mode = true
    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = data.aws_caller_identity.current.account_id
    }
    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = data.aws_region.current.name
    }
    environment_variable {
      name  = "CONTAINER_NAME"
      value = var.container_name
    }
    environment_variable {
      name  = "IMAGE_REPO_NAME"
      value = var.image_repo_name
    }
  }
  artifacts {
    type = "CODEPIPELINE"
  }
}

resource "aws_codebuild_project" "batch" {
  name         = local.batch_buildprojec_name
  service_role = aws_iam_role.codebuild_batch_role.arn

  source {
    type                = "CODEPIPELINE"
    git_clone_depth     = 0
    insecure_ssl        = false
    report_build_status = false
    buildspec           = file("./file/buildspec_batch.yml")
  }
  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/amazonlinux2-aarch64-standard:3.0-24.06.07"
    type            = "ARM_CONTAINER"
    privileged_mode = true
    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = data.aws_caller_identity.current.account_id
    }
    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = data.aws_region.current.name
    }
    environment_variable {
      name  = "CONTAINER_NAME"
      value = var.batch_container_name
    }
    environment_variable {
      name  = "IMAGE_REPO_NAME"
      value = var.batch_image_repo_name
    }
  }
  artifacts {
    type = "CODEPIPELINE"
  }
}

# マイグレーション用のIAMロール
resource "aws_iam_role" "codebuild_migration_role" {
  name = local.codebuild_migration_project_role
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Principal = { Service = "codebuild.amazonaws.com" },
      Effect    = "Allow"
    }]
  })
}

resource "aws_iam_policy" "codebuild_migration_build_policy" {
  name = local.codebuild_migration_build_policy
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:PutObject"
        ],
        Resource = "${aws_s3_bucket.pipeline.arn}/*"
      },
      {
        Effect = "Allow",
        Action = [
          "ecs:RunTask",
          "ecs:DescribeTasks",
          "iam:PassRole"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codebuild_migration_build_policy_attach" {
  role       = aws_iam_role.codebuild_migration_role.name
  policy_arn = aws_iam_policy.codebuild_migration_build_policy.arn
}

# マイグレーション用のCodeBuildプロジェクト
resource "aws_codebuild_project" "migration" {
  name         = local.migration_buildprojec_name
  service_role = aws_iam_role.codebuild_migration_role.arn

  source {
    type        = "CODEPIPELINE"
    # 外部YAMLファイルでCodeBuildのYAML解析エラーが発生したため、
    # インラインでヒアドキュメント（<<BUILDSPEC）を使用してbuildspecを定義
    # これによりYAML構文解析の問題を回避し、特に条件文（if文）の処理を正常に行えるようにする
    buildspec   = <<BUILDSPEC
version: 0.2
phases:
  build:
    commands:
      - echo "Starting migration task"
      - TASK_ARN=$(aws ecs run-task --cluster $ECS_CLUSTER_NAME --task-definition $MIGRATION_TASK_DEFINITION --network-configuration "awsvpcConfiguration={subnets=[$PRIVATE_SUBNET_IDS],securityGroups=[$ECS_SECURITY_GROUP_ID],assignPublicIp=DISABLED}" --launch-type FARGATE --query 'tasks[0].taskArn' --output text)
      - echo "Task ARN $TASK_ARN"
      - echo "Waiting for task to complete"
      - aws ecs wait tasks-stopped --cluster $ECS_CLUSTER_NAME --tasks $TASK_ARN
      - echo "Task has stopped, checking status"
      - TASK_STATUS=$(aws ecs describe-tasks --cluster $ECS_CLUSTER_NAME --tasks $TASK_ARN --query 'tasks[0].containers[0].exitCode' --output text)
      - echo "Task status code $TASK_STATUS"
      - echo "Checking if status is None or null"
      - "if [ \"$TASK_STATUS\" = \"None\" ] || [ \"$TASK_STATUS\" = \"null\" ]; then echo \"Task executed but no exit code. Check ECS console for details.\"; else if [ \"$TASK_STATUS\" != \"0\" ]; then echo \"Migration failed with exit code $TASK_STATUS\"; exit 1; fi; fi"
      - echo "Migration completed successfully"
BUILDSPEC
  }
  
  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/amazonlinux2-aarch64-standard:3.0-24.06.07"
    type            = "ARM_CONTAINER"
    privileged_mode = true
    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = data.aws_caller_identity.current.account_id
    }
    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = data.aws_region.current.name
    }
    environment_variable {
      name  = "ECS_CLUSTER_NAME"
      value = var.ecs_cluster_name
    }
    environment_variable {
      name  = "MIGRATION_TASK_DEFINITION"
      value = data.terraform_remote_state.infra.outputs.migration_task_definition
    }
    environment_variable {
      name  = "PRIVATE_SUBNET_IDS"
      value = data.terraform_remote_state.infra.outputs.private_subnet_ids
    }
    environment_variable {
      name  = "ECS_SECURITY_GROUP_ID"
      value = data.terraform_remote_state.infra.outputs.ecs_security_group_id
    }
  }
  
  artifacts {
    type = "CODEPIPELINE"
  }
}
