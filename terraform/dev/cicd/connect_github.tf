resource "aws_codestarconnections_connection" "github" {
  name          = "github-city-gas"
  provider_type = "GitHub"
  tags = {
    Name = "github-city-gas"
  }
}