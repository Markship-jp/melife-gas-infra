terraform {
  backend "s3" {
    bucket = "stg-melife-gas-tfstate"
    key    = "cicd/terraform.tfstate"
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
      env        = "stg"
    }
  }
}

provider "aws" {
  alias = "n-virginia"
  region = "us-east-1"
  default_tags {
    tags = {
      managed_by = "terraform",
      env        = "stg"
    }
  }
}

