locals {
  ecr_repository_name= "${var.env}-${var.project}-ecr-repository"
  ecr_batch_repository_name = "${var.env}-${var.project}-batch-ecr-repository"
}

resource "aws_ecr_registry_scanning_configuration" "main" {
  scan_type = "BASIC"

  rule {
    repository_filter {
      filter      = "*"
      filter_type = "WILDCARD"
    }
    scan_frequency = "SCAN_ON_PUSH"
  }
}

resource "aws_ecr_repository" "main" {
  name                     = local.ecr_repository_name
  image_tag_mutability     = "MUTABLE"  
  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Name = local.ecr_repository_name
  } 
}

resource "aws_ecr_lifecycle_policy" "main" {
  repository = aws_ecr_repository.main.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "latestタグ"
        selection = {
          tagStatus     = "tagged"
          tagPatternList = ["latest"]
          countType     = "imageCountMoreThan"
          countNumber   = 1
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "それ以外のタグ"
        selection = {
          tagStatus     = "tagged"
          tagPatternList = ["*"]
          countType     = "imageCountMoreThan"
          countNumber   = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}


resource "aws_ecr_repository" "batch" {
  name                     = local.ecr_batch_repository_name
  image_tag_mutability     = "MUTABLE"  
  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Name = local.ecr_batch_repository_name
  }
}

resource "aws_ecr_lifecycle_policy" "batch" {
  repository = aws_ecr_repository.batch.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "latestタグ"
        selection = {
          tagStatus     = "tagged"
          tagPatternList = ["latest"]
          countType     = "imageCountMoreThan"
          countNumber   = 1
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "それ以外のタグ"
        selection = {
          tagStatus     = "tagged"
          tagPatternList = ["*"]
          countType     = "imageCountMoreThan"
          countNumber   = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

