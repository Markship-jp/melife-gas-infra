# Local variables

locals {
  ecr_repository_name= "${var.env}-${var.project}-ecr-repository"
}

resource "aws_ecr_repository" "main" {
  name                     = local.ecr_repository_name
  image_tag_mutability     = "MUTABLE"  
  encryption_configuration {
    encryption_type = "AES256"
  }

  image_scanning_configuration {
    scan_on_push = false
  }
}