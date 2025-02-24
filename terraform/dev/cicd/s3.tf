locals {
  s3_name_pipeline = "${var.env}-${var.project}-ecs-deploy"
}
resource "aws_s3_bucket" "pipeline" {
  bucket = local.s3_name_pipeline

    tags = {
    Name = local.s3_name_pipeline
  }
}