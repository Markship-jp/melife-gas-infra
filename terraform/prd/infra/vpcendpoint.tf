# Local variables

locals {
  vpcendpoint_s3_name   = "${var.env}-${var.project}-vpcendpoint-s3"   
}

resource "aws_vpc_endpoint" "main" {
  service_name = "com.amazonaws.${data.aws_region.current.name}.s3"
  vpc_id = aws_vpc.main.id
  vpc_endpoint_type = "Gateway"
  route_table_ids = [
    aws_route_table.public_app_1a.id,
    aws_route_table.public_app_1c.id,
    aws_route_table.private_app_1a.id,
    aws_route_table.private_app_1c.id,
    aws_route_table.private_db_1a.id,
    aws_route_table.private_db_1c.id
  ]

  tags = {
    Name = local.vpcendpoint_s3_name
  }  
}