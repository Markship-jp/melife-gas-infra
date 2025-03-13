# Locals

locals {
  sg_name_ecs            = "${var.env}-${var.project}-sg-ecs"
  sg_name_db             = "${var.env}-${var.project}-sg-db"
  sg_name_alb            = "${var.env}-${var.project}-sg-alb"
  sg_name_batch          = "${var.env}-${var.project}-sg-batch"
}

# Security Group

# ECS

resource "aws_security_group" "ecs" {
  name        = local.sg_name_ecs
  description = "Security Group for front ECS "
  vpc_id      = aws_vpc.main.id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = local.sg_name_ecs
  }
}

resource "aws_security_group_rule" "ecs_ingress_http" {
  description              = "Permit access from ALB"
  type                     = "ingress"
  from_port                = 3000
  to_port                  = 3000
  protocol                 = "tcp"
  security_group_id        = aws_security_group.ecs.id
  source_security_group_id = aws_security_group.alb.id
}

# Batch
resource "aws_security_group" "batch" {
  name        = local.sg_name_batch
  description = "Security Group for Batch ECS"
  vpc_id      = aws_vpc.main.id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = local.sg_name_batch
  }
}

# Aurora

resource "aws_security_group" "db" {
  name        = local.sg_name_db
  description = "Security Group for Database"
  vpc_id      = aws_vpc.main.id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = local.sg_name_db
  }
}

resource "aws_security_group_rule" "db" {
  description              = "Permit access from ECS"
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = aws_security_group.db.id
  source_security_group_id = aws_security_group.ecs.id
}

resource "aws_security_group_rule" "db_batch" {
  description              = "Permit access from Batch ECS"
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = aws_security_group.db.id
  source_security_group_id = aws_security_group.batch.id
}

# ALB

resource "aws_security_group" "alb" {
  name        = local.sg_name_alb
  description = "Security Group for ALB"
  vpc_id      = aws_vpc.main.id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = local.sg_name_alb
  }
}

resource "aws_security_group_rule" "alb_ingress_http" {
  description       = "Permit access from HTTP"
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.alb.id
  cidr_blocks       = ["0.0.0.0/0"]
}


resource "aws_security_group_rule" "alb_ingress_https" {
  description       = "Permit access from HTTPS"
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.alb.id
  cidr_blocks       = ["0.0.0.0/0"]
}
