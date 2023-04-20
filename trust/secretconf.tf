
resource "vault_aws_secret_backend" "aws" {
  access_key = "AWS access key"
  secret_key = "AWS secret key"
}

resource "vault_aws_secret_backend_role" "role" {
  backend = vault_aws_secret_backend.aws.path
  name    = "aws-role"
  credential_type = "iam_user"

  policy_document = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "iam:*",
        "ec2:*"
      ],
      "Resource": "*"
    }
  ]
}
EOT
}

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
