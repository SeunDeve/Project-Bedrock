# -----------------------------------------------------------------------------
# BOOTSTRAP — run this ONCE, manually, before touching the main root module.
#
# Why this exists as a separate root module:
# Terraform can't configure an S3 backend that doesn't exist yet. So we spin
# up the state bucket itself using plain local state, then never touch this
# module again (it's not part of the CI/CD pipeline).
#
# Usage:
# cd terraform/bootstrap
# terraform init
# terraform apply
# # note the bucket name in the output, then plug it into ../backend.tf
# -----------------------------------------------------------------------------
terraform {
  required_version = ">= 1.11.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.60"
    }
  }
  # Intentionally local state here — chicken/egg problem.
}
provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      Project = "tinyuka-2025-capstone"
    }
  }
}
resource "aws_s3_bucket" "tf_state" {
  bucket = "bedrock-tfstate-${data.aws_caller_identity.current.account_id}"
  # Safety net: prevents `terraform destroy` from nuking your state bucket
  # by accident while other infra still depends on it.
  lifecycle {
    prevent_destroy = true
  }
}
resource "aws_s3_bucket_versioning" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id
  versioning_configuration {
    status = "Enabled"
  }
}
resource "aws_s3_bucket_server_side_encryption_configuration" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
resource "aws_s3_bucket_public_access_block" "tf_state" {
  bucket                  = aws_s3_bucket.tf_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
data "aws_caller_identity" "current" {}
output "state_bucket_name" {
  value       = aws_s3_bucket.tf_state.id
  description = "Plug this into terraform/backend.tf as the `bucket` value"
}