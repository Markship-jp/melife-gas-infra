# Identifer

variable "env" {
  default = "dev"
}

variable "project" {
  default = "melife-gas"
}

variable "domain_name" {
  default = ""
}

# Network(環境毎に値が変わる点に留意すること)
# VPC CIDR
variable "vpc_cidr" {
  default = "10.30.0.0/16"
}

# Subnet CIDR
variable "subnets" {
  default = {
    # Ingress用パブリックサブネット
    public_app_1a = "10.30.0.0/24"
    public_app_1c = "10.30.1.0/24"
    # アプリケーション用サブネット(フロント・バックエンド含む)
    private_app_1a = "10.30.8.0/24"
    private_app_1c = "10.30.9.0/24"
    # データベース用サブネット
    private_db_1a = "10.30.16.0/24"
    private_db_1c = "10.30.17.0/24"
  }
}

# Availability Zone
variable "availability_zones" {
  default = {
    az-1a = "ap-northeast-1a"
    az-1c = "ap-northeast-1c"
  }
}