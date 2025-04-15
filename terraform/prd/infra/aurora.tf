# Locals

locals {
  rds_name_subnet_group             = "${var.env}-${var.project}-rds-subnet-group"
  rds_name_cluster_parameter_group  = "${var.env}-${var.project}-rds-cluster-parameter-group"
  rds_name_instance_parameter_group = "${var.env}-${var.project}-rds-instance-parameter-group"
  cluster_identifier                = "${var.env}-${var.project}-aurora"
  database_name                     = "${var.env}_db"
  aurora_instance_identifier        = "${var.env}-${var.project}-aurora-instance"
  aurora_admin_username             = "${var.env}_admin"
}

# Parameter for Database

resource "random_password" "main" {
  length           = 10
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# ランダム文字列で生成したパスワードの値をParameter Storeに保管

resource "aws_ssm_parameter" "main" {
  name  = "/${var.env}/${var.project}/db"
  type  = "SecureString"
  value = random_password.main.result

  lifecycle {
    ignore_changes = [value]
  }
}

# Subnet group for Aurora Database"

resource "aws_db_subnet_group" "main" {
  name        = local.rds_name_subnet_group
  description = "Subnet group for Aurora Database"

  subnet_ids = [
    aws_subnet.private_db_1a.id,
    aws_subnet.private_db_1c.id
  ]

  tags = {
    Name = local.rds_name_subnet_group
  }
}

# Parameter Group
# Cluster

resource "aws_rds_cluster_parameter_group" "main" {
  name        = local.rds_name_cluster_parameter_group
  family      = "aurora-mysql8.0"
  description = "Parameter Group for Aurora Cluster"

  parameter {
    name  = "time_zone"
    value = "Asia/Tokyo"
  }

  parameter {
    name  = "slow_query_log"
    value = "1"
  }

  parameter {
    name  = "server_audit_logging"
    value = "1"
  }

  parameter {
    name  = "server_audit_events"
    value = "CONNECT,QUERY,QUERY_DCL,QUERY_DDL,QUERY_DML,TABLE"
  }

  tags = {
    Name = local.rds_name_cluster_parameter_group
  }
}

# Instance

resource "aws_db_parameter_group" "main" {
  name        = local.rds_name_instance_parameter_group
  family      = "aurora-mysql8.0"
  description = "Parameter Group for Aurora Instance"

  tags = {
    Name = local.rds_name_instance_parameter_group
  }
}

# -----------------------------
# Aurora Cluster
# -----------------------------
resource "aws_rds_cluster" "aurora_cluster" {
  cluster_identifier = local.cluster_identifier
  database_name      = local.database_name
  engine             = "aurora-mysql"
  backup_retention_period         = 3
  preferred_backup_window         = "18:00-19:00"
  master_username                 = local.aurora_admin_username
  engine_version                  = "8.0.mysql_aurora.3.08.0"
  preferred_maintenance_window    = "sat:15:00-sat:15:30"
  master_password                 = aws_ssm_parameter.main.value
  db_subnet_group_name            = aws_db_subnet_group.main.name
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.main.name
  vpc_security_group_ids          = [aws_security_group.db.id]
  skip_final_snapshot             = true
  storage_encrypted               = true
  apply_immediately               = true
  port                            = 3306
  enabled_cloudwatch_logs_exports = ["slowquery", "audit"]
  backtrack_window = 86400 #24時間


  tags = {
    Name          = local.cluster_identifier
  }
}

# -----------------------------
# Aurora DB Instance
# -----------------------------
resource "aws_rds_cluster_instance" "aurora_instance" {
  count                                 = 1
  apply_immediately                     = true
  identifier                            = "${local.aurora_instance_identifier}-${count.index + 1}"
  cluster_identifier                    = aws_rds_cluster.aurora_cluster.id
  instance_class                        = "db.r8g.large"
  engine                                = aws_rds_cluster.aurora_cluster.engine
  db_subnet_group_name                  = aws_db_subnet_group.main.name
  db_parameter_group_name               = aws_db_parameter_group.main.name
  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  preferred_maintenance_window          = "sat:1${count.index + 5}:00-sat:1${count.index + 5}:30"
  auto_minor_version_upgrade            = false
  ca_cert_identifier                    = "rds-ca-rsa2048-g1"


  tags = {
    Name = local.aurora_instance_identifier
  }
}
