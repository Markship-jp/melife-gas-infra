# IAM
locals {
  codebuild_build_policy = "${var.env}-${var.project}-codebuild-build-policy"
  codebuild_ecr_policy   = "${var.env}-${var.project}-codebuild-ecr-policy"
  codebuild_project_role = "${var.env}-${var.project}-codebuild-project-role"
  codebuild_batch_project_role = "${var.env}-${var.project}-codebuild-batch-project-role"
  codebuild_batch_build_policy = "${var.env}-${var.project}-codebuild-batch-build-policy"
  buildprojec_name       = "${var.env}-${var.project}-buildproject"
  batch_buildprojec_name = "${var.env}-${var.project}-batch-buildproject"
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
