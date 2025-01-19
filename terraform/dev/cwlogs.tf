# Locals

locals {
  loggroup_name_rds_slowquery  = "/aws/rds/cluster/${var.env}-${var.project}-aurora/slowquery"
  loggroup_name_rds_audit      = "/aws/rds/cluster/${var.env}-${var.project}-aurora/audit"
  loggroup_name_ecs    = "/aws/ecs/${var.env}-${var.project}"
}

# Slowqueryログ

resource "aws_cloudwatch_log_group" "slowquery" {
  name              = local.loggroup_name_rds_slowquery
  retention_in_days = 30
  skip_destroy      = true
  tags = {
    Name = local.loggroup_name_rds_slowquery
  }
}

# Auditログ(本番環境のみ)
# resource "aws_cloudwatch_log_group" "audit" {
#   name              = local.loggroup_name_rds_audit
#   retention_in_days = 30
#   skip_destroy      = true
#   tags = {
#     Name = local.loggroup_name_rds_audit
#   }
# }

# ECSログ
resource "aws_cloudwatch_log_group" "ecs" {
  name              = local.loggroup_name_ecs
  retention_in_days = 30
  skip_destroy      = true
  tags = {
    Name = local.loggroup_name_ecs
  }
}