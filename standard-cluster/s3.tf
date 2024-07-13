# Retrieve the current AWS account ID and region
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Retrieve the EKS cluster details
data "aws_eks_cluster" "cluster" {
  depends_on = [module.eks]
  name = module.eks.cluster_name 
}

locals {
  oidc_issuer_url = replace(data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "")
}

resource "random_string" "postfix" {
  length  = 5
  special = false
  upper   = false
}

resource "aws_s3_bucket" "loki_bucket" {
  #bucket = "loki-xi1f34"
  bucket = "loki-${random_string.postfix.result}"
  acl    = "private"

  versioning {
    enabled = true
  }

  force_destroy = true

}

resource "aws_s3_bucket_lifecycle_configuration" "loki_bucket_lifecycle" {
  bucket = aws_s3_bucket.loki_bucket.id

  rule {
    id     = "transition-to-glacier"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "GLACIER"
    }

    expiration {
      days = 90
    }
  }
}

resource "aws_s3_bucket_public_access_block" "loki_bucket_access_block" {
  bucket = aws_s3_bucket.loki_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Create an IAM role for the Kubernetes service account
resource "aws_iam_role" "loki_s3_role" {
  name = "loki-s3-role"

  # Trust policy to allow the Kubernetes service account to assume the role
  assume_role_policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Federated": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.oidc_issuer_url}"
        },
        "Action": "sts:AssumeRoleWithWebIdentity",
        "Condition": {
          "StringEquals": {
            "${local.oidc_issuer_url}:sub": "system:serviceaccount:loki-stack:loki-sa",
            "${local.oidc_issuer_url}:aud": "sts.amazonaws.com"
          }
        }
      }
    ]
  }
  EOF
}

# Attach the necessary permissions to the IAM role
resource "aws_iam_role_policy" "loki_s3_policy" {
  name = "loki-s3-policy"
  role = aws_iam_role.loki_s3_role.name

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ],
        "Resource": [
          "${aws_s3_bucket.loki_bucket.arn}",
          "${aws_s3_bucket.loki_bucket.arn}/*"
        ]
      }
    ]
  }
  EOF
}

output "loki_bucket_name" {
  value = aws_s3_bucket.loki_bucket.id
}

output "oidc_issuer_url"{
  value = local.oidc_issuer_url
}
