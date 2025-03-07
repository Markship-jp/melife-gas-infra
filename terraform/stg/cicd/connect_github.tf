resource "aws_codestarconnections_connection" "github" {
  name          = "${var.env}-${var.project}-github-connection"
  provider_type = "GitHub"
  tags = {
    Name = "${var.env}-${var.project}-github-connection"
  }
}