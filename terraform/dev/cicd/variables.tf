# Identifer

variable "env" {
  default = "dev"
}

variable "project" {
  default = "melife-gas"
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
