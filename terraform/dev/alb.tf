# Locals

locals {
  alb_name_app    = "${var.env}-${var.project}-alb"
  alb_name_app_tg = "${var.env}-${var.project}-tg"
}

# ALB
resource "aws_lb" "main" {
  name               = local.alb_name_app
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [aws_subnet.public_app_1a.id, aws_subnet.public_app_1c.id]
  idle_timeout = 300
  access_logs {
    bucket  = aws_s3_bucket.alb_access_logs.id
    enabled = true
  }
}

# Target group
resource "aws_lb_target_group" "main" {
  name        = local.alb_name_app_tg
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    enabled             = true
    interval            = 30
    path                = "/login"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}



# # Listener HTTP
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}

# Listener HTTPS
# resource "aws_lb_listener" "https" {
#   load_balancer_arn = aws_lb.main.arn
#   port              = "443"
#   protocol          = "HTTPS"
#   ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
#   certificate_arn   = aws_acm_certificate.main.arn
#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.main.arn
#   }
# }

