terraform {
  backend "s3" {
    bucket = "dev-melife-gas-tfstate"
    key    = "terraform.tfstate"
    region = "ap-northeast-1"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "ap-northeast-1"
  default_tags {
    tags = {
      managed_by = "terraform",
      env        = "dev"
    }
  }
}