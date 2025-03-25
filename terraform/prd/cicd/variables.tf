# Identifer

variable "env" {
  default = "prd"
}

variable "project" {
  default = "melife-gas"
}

variable "github_repository_id" {
  description = "GitHub repository ID(Example:your-github-org-or-user/your-repo-name)"
  type        = string
  default = "acomic/city-gas"
}

# -----------------------------
# App
# ----------------------------- 
variable "container_name" {
  description = "Container name"
  type        = string
  default = "prd-melife-gas-ecs-container"
}

variable "image_repo_name" {
  description = "ECR Repository Name"
  type        = string
  default = "prd-melife-gas-ecr-repository"
}

variable "branch_name" {
  description = "Branch name"
  type        = string
  default = "main"
}

variable "ecs_cluster_name" {
  description = "ECS cluster name for deployment"
  type        = string
  default     = "prd-melife-gas-ecs-cluster"
}

variable "ecs_service_name" {
  description = "ECS service name for deployment"
  type        = string
  default     = "prd-melife-gas-ecs-service"
}

# -----------------------------
# Batch
# ----------------------------- 
variable "batch_container_name" {
  description = "Container name"
  type        = string
  default = "prd-melife-gas-batch-container"
}

variable "batch_image_repo_name" {
  description = "ECR Repository Name"
  type        = string
  default = "prd-melife-gas-batch-ecr-repository"
}

variable "batch_branch_name" {
  description = "Branch name"
  type        = string
  default = "main"
} 

