locals {
    parameterstore_path            = "/${var.env}/${var.project}"
}

resource "aws_ssm_parameter" "DATABASE_URL" {
  name  = "${local.parameterstore_path}/DATABASE_URL"
  type  = "SecureString"
  value = "PLACEHOLDER" # セキュアストリングの値はコンソールに設定するため仮の値を設定
  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "AUTH_TOKEN_SECRET" {
  name  = "${local.parameterstore_path}/AUTH_TOKEN_SECRET"
  type  = "SecureString"
  value = "PLACEHOLDER" # セキュアストリングの値はコンソールに設定するため仮の値を設定
  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "FRONTEND_HOST" {
  name  = "${local.parameterstore_path}/FRONTEND_HOST"
  type  = "SecureString"
  value = "PLACEHOLDER" # セキュアストリングの値はコンソールに設定するため仮の値を設定
  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "MAIL_HOST" {
  name  = "${local.parameterstore_path}/MAIL_HOST"
  type  = "SecureString"
  value = "PLACEHOLDER" # セキュアストリングの値はコンソールに設定するため仮の値を設定
  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "MAIL_PORT" {
  name  = "${local.parameterstore_path}/MAIL_PORT"
  type  = "SecureString"
  value = "PLACEHOLDER" # セキュアストリングの値はコンソールに設定するため仮の値を設定
  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "MAIL_USERNAME" {
  name  = "${local.parameterstore_path}/MAIL_USERNAME"
  type  = "SecureString"
  value = "PLACEHOLDER" # セキュアストリングの値はコンソールに設定するため仮の値を設定
  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "MAIL_PASSWORD" {
  name  = "${local.parameterstore_path}/MAIL_PASSWORD"
  type  = "SecureString"
  value = "PLACEHOLDER" # セキュアストリングの値はコンソールに設定するため仮の値を設定
  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "MAIL_FROM_ADDRESS" {
  name  = "${local.parameterstore_path}/MAIL_FROM_ADDRESS"
  type  = "SecureString"
  value = "PLACEHOLDER" # セキュアストリングの値はコンソールに設定するため仮の値を設定
  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "ZIPCODE_APIKEY" {
  name  = "${local.parameterstore_path}/ZIPCODE_APIKEY"
  type  = "SecureString"
  value = "PLACEHOLDER" # セキュアストリングの値はコンソールに設定するため仮の値を設定
  lifecycle {
    ignore_changes = [value]
  }
}
