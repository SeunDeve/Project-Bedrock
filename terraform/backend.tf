terraform {
  backend "s3" {
    bucket       = "bedrock-tfstate-123456789012"
    key          = "project-bedrock/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}