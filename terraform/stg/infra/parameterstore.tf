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

resource "aws_ssm_parameter" "ZIPCODE_API_KEY" {
  name  = "${local.parameterstore_path}/ZIPCODE_API_KEY"
  type  = "SecureString"
  value = "PLACEHOLDER" # セキュアストリングの値はコンソールに設定するため仮の値を設定
  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "PAYGENT_MERCHANT_ID" {
  name  = "${local.parameterstore_path}/PAYGENT_MERCHANT_ID"
  type  = "SecureString"
  value = "PLACEHOLDER" # セキュアストリングの値はコンソールに設定するため仮の値を設定
  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "PAYGENT_MERCHANT_NAME" {
  name  = "${local.parameterstore_path}/PAYGENT_MERCHANT_NAME"
  type  = "SecureString"
  value = "PLACEHOLDER" # セキュアストリングの値はコンソールに設定するため仮の値を設定
  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "PAYGENT_HASH_KEY" {
  name  = "${local.parameterstore_path}/PAYGENT_HASH_KEY"
  type  = "SecureString"
  value = "PLACEHOLDER" # セキュアストリングの値はコンソールに設定するため仮の値を設定
  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "PAYGENT_COMPANY_NAME" {
  name  = "${local.parameterstore_path}/PAYGENT_COMPANY_NAME"
  type  = "SecureString"
  value = "PLACEHOLDER" # セキュアストリングの値はコンソールに設定するため仮の値を設定
  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "PAYGENT_LINK_URL" {
  name  = "${local.parameterstore_path}/PAYGENT_LINK_URL"
  type  = "SecureString"
  value = "PLACEHOLDER" # セキュアストリングの値はコンソールに設定するため仮の値を設定
  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "PAYGENT_CONNECT_ID" {
  name  = "${local.parameterstore_path}/PAYGENT_CONNECT_ID"
  type  = "SecureString"
  value = "PLACEHOLDER" # セキュアストリングの値はコンソールに設定するため仮の値を設定
  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "PAYGENT_CONNECT_PASSWORD" {
  name  = "${local.parameterstore_path}/PAYGENT_CONNECT_PASSWORD"
  type  = "SecureString"
  value = "PLACEHOLDER" # セキュアストリングの値はコンソールに設定するため仮の値を設定
  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "PAYGENT_CONNECT_VERSION" {
  name  = "${local.parameterstore_path}/PAYGENT_CONNECT_VERSION"
  type  = "SecureString"
  value = "PLACEHOLDER" # セキュアストリングの値はコンソールに設定するため仮の値を設定
  lifecycle {
    ignore_changes = [value]
  }
}


resource "aws_ssm_parameter" "PAYGENT_PFX_PASSWORD" {
  name  = "${local.parameterstore_path}/PAYGENT_PFX_PASSWORD"
  type  = "SecureString"
  value = "PLACEHOLDER" # セキュアストリングの値はコンソールに設定するため仮の値を設定
  lifecycle {
    ignore_changes = [value]
  }
}


resource "aws_ssm_parameter" "PAYGENT_PFX_KEY" {
  name  = "${local.parameterstore_path}/PAYGENT_PFX_KEY"
  type  = "SecureString"
  value = "PLACEHOLDER" # セキュアストリングの値はコンソールに設定するため仮の値を設定
  lifecycle {
    ignore_changes = [value]
  }
}


resource "aws_ssm_parameter" "PAYGENT_MODULE_CONNECT_URL" {
  name  = "${local.parameterstore_path}/PAYGENT_MODULE_CONNECT_URL"
  type  = "SecureString"
  value = "PLACEHOLDER" # セキュアストリングの値はコンソールに設定するため仮の値を設定
  lifecycle {
    ignore_changes = [value]
  }
}


resource "aws_ssm_parameter" "AWS_DOWNLOAD_BUCKET_NAME" {
  name  = "${local.parameterstore_path}/AWS_DOWNLOAD_BUCKET_NAME"
  type  = "SecureString"
  value = "PLACEHOLDER" # セキュアストリングの値はコンソールに設定するため仮の値を設定
  lifecycle {
    ignore_changes = [value]
  }
}