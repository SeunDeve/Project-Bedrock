terraform {
backend "s3" {
bucket = "bedrock-tfstate-REPLACE_WITH_ACCOUNT_ID"
key = "project-bedrock/terraform.tfstate"
region = "us-east-1"
encrypt = true
use_lockfile = true
}
}