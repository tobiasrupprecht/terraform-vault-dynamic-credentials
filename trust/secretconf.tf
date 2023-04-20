#### Proper way with HashiCorp Account ####
# Setting up prereqs for using HC Account

locals {
  my_email = split("/", data.aws_caller_identity.current.arn)[2]
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

# Vault Mount AWS Config Setup

data "aws_iam_policy" "demo_user_permissions_boundary" {
  name = "DemoUser"
}

resource "aws_iam_user" "vault_mount_user" {
  name                 = "demo-${local.my_email}"
  permissions_boundary = data.aws_iam_policy.demo_user_permissions_boundary.arn
  force_destroy        = true
}

resource "aws_iam_user_policy" "vault_mount_user" {
  user   = aws_iam_user.vault_mount_user.name
  policy = data.aws_iam_policy.demo_user_permissions_boundary.policy
  name   = "DemoUserInlinePolicy"
}

resource "aws_iam_access_key" "vault_mount_user" {
  user = aws_iam_user.vault_mount_user.name
}

# Vault Mount AWS Role Setup
data "aws_iam_policy_document" "vault_dynamic_iam_user_policy" {
  statement {
    sid       = "VaultDemoUserDescribeEC2Regions"
    actions   = ["ec2:DescribeRegions"]
    resources = ["*"]
  }
}

data "aws_iam_role" "vault_target_iam_role" {
  name = "vault-assumed-role-credentials-demo"
}




# Create AWS Secret Engine
resource "vault_aws_secret_backend" "aws" {
  access_key        = aws_iam_access_key.vault_mount_user.id
  secret_key        = aws_iam_access_key.vault_mount_user.secret
  description       = "Demo of the AWS secrets engine"
  region            = data.aws_region.current.name
  username_template = "{{ if (eq .Type \"STS\") }}{{ printf \"${aws_iam_user.vault_mount_user.name}-%s-%s\" (random 20) (unix_time) | truncate 32 }}{{ else }}{{ printf \"${aws_iam_user.vault_mount_user.name}-vault-%s-%s\" (unix_time) (random 20) | truncate 60 }}{{ end }}"
}

# Create Role
resource "vault_aws_secret_backend_role" "vault_role_iam_user_credential_type" {
  backend                  = vault_aws_secret_backend.vault_aws.path
  credential_type          = "iam_user"
  name                     = "vault-demo-iam-user"
  permissions_boundary_arn = data.aws_iam_policy.demo_user_permissions_boundary.arn
  policy_document          = data.aws_iam_policy_document.vault_dynamic_iam_user_policy.json
}

######### Easy way with Private Account #########
#resource "vault_aws_secret_backend" "aws" {
#  access_key = "AWS access key"
#  secret_key = "AWS secret key"
#}

#resource "vault_aws_secret_backend_role" "role" {
#  backend = vault_aws_secret_backend.aws.path
#  name    = "aws-role"
#  credential_type = "iam_user"

##  policy_document = <<EOT
#{
#  "Version": "2012-10-17",
#  "Statement": [
#    {
#      "Effect": "Allow",
#      "Action": [
#        "iam:*",
#        "ec2:DescribeRegions"
#      ],
#      "Resource": "*"
#    }
#  ]
#}
#EOT
#}


resource "vault_mount" "kvv2" {
  path        = "example"
  type        = "kv"
  options     = { version = "2" }
  description = "KV Version 2 secret engine mount"
}

resource "vault_kv_secret_v2" "example" {
  mount                      = vault_mount.kvv2.path
  name                       = "awsSecrets"
  data_json                  = jsonencode(
  {
    AWS_ACCESS_KEY        = "foo",
    AWS_SECRET_ACCESS_KEY = "bar"
  }
  )
}
