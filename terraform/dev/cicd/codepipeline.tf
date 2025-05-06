# CodePipeline用IAMロール
locals {
  codepipeline_role = "${var.env}-${var.project}-codepipeline-role"
  codepipeline_policy = "${var.env}-${var.project}-codepipeline-policy"
  batch_codepipeline_role = "${var.env}-${var.project}-batch-codepipeline-role"
  batch_codepipeline_policy = "${var.env}-${var.project}-batch-codepipeline-policy"
}

resource "aws_iam_role" "codepipeline_role" {
  name = local.codepipeline_role
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Principal = { Service = "codepipeline.amazonaws.com" },
      Effect    = "Allow"
    }]
  })
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name = local.codepipeline_policy
  role = aws_iam_role.codepipeline_role.id
  
  policy = templatefile("./file/codepipeline_ecs_deploy_policy.json.tpl", {
    S3_BUCKET_ARN     = aws_s3_bucket.pipeline.arn
    GITHUB_CONNECTION = aws_codestarconnections_connection.github.arn
    CODEBUILD_ARN     = jsonencode([aws_codebuild_project.app.arn, aws_codebuild_project.migration.arn])
    BATCH_CODEBUILD_ARN = ""
  })
}

# ECS Run Task用のポリシーを追加
resource "aws_iam_role_policy" "codepipeline_run_task_policy" {
  name = "${var.env}-${var.project}-codepipeline-runtask-policy"
  role = aws_iam_role.codepipeline_role.id
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ecs:RunTask",
          "iam:PassRole"
        ],
        Resource = "*"
      }
    ]
  })
}

# バッチ用CodePipelineロール
resource "aws_iam_role" "batch_codepipeline_role" {
  name = local.batch_codepipeline_role
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Principal = { Service = "codepipeline.amazonaws.com" },
      Effect    = "Allow"
    }]
  })
}

resource "aws_iam_role_policy" "batch_codepipeline_policy" {
  name = local.batch_codepipeline_policy
  role = aws_iam_role.batch_codepipeline_role.id
  
  policy = templatefile("./file/codepipeline_ecs_deploy_policy.json.tpl", {
    S3_BUCKET_ARN     = aws_s3_bucket.pipeline.arn
    GITHUB_CONNECTION = aws_codestarconnections_connection.github.arn
    CODEBUILD_ARN     = jsonencode([aws_codebuild_project.batch.arn])
    BATCH_CODEBUILD_ARN = ""
  })
}

# CodePipeline
resource "aws_codepipeline" "my_app_pipeline" {
  name     = "${var.env}-${var.project}-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    type     = "S3"
    location = aws_s3_bucket.pipeline.bucket
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = aws_codestarconnections_connection.github.arn
        FullRepositoryId = var.github_repository_id
        BranchName       = var.branch_name
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]

      configuration = {
        ProjectName = local.buildprojec_name
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      version         = "1"
      input_artifacts = ["build_output"]

      configuration = {
        ClusterName = var.ecs_cluster_name
        ServiceName = var.ecs_service_name
        FileName    = "imagedefinitions.json"
      }
    }
  }

  stage {
    name = "Migration"

    action {
      name            = "RunMigration"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["build_output"]
      
      configuration = {
        ProjectName = aws_codebuild_project.migration.name
      }
    }
  }
}

resource "aws_codepipeline" "batch_app_pipeline" {
  name     = "${var.env}-${var.project}-batch-pipeline"
  role_arn = aws_iam_role.batch_codepipeline_role.arn

  artifact_store {
    type     = "S3"
    location = aws_s3_bucket.pipeline.bucket
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = aws_codestarconnections_connection.github.arn
        FullRepositoryId = var.github_repository_id
        BranchName       = var.batch_branch_name
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]

      configuration = {
        ProjectName = local.batch_buildprojec_name
      }
    }
  }
}