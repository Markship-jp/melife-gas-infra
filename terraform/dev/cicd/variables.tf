# Identifer

variable "env" {
  default = "dev"
}

variable "project" {
  default = "melife-gas"
}

variable "github_connection_arn" {
  description = "AWS Connector for GitHub Connection ARN"
  type        = string
  default = "arn:aws:codeconnections:ap-northeast-1:980921747859:connection/e5fb9a6a-8516-4840-982b-31a38be536fb"
}

variable "github_repository_id" {
  description = "GitHub repository ID(Example:your-github-org-or-user/your-repo-name)"
  type        = string
  default = ""
}

variable "container_name" {
  description = "Container name"
  type        = string
  default = ""
}

variable "image_repo_name" {
  description = "ECR Repository Name"
  type        = string
  default = "dev-melife-gas-ecr-repository"
}
