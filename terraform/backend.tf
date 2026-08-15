terraform {
  backend "s3" {
    bucket       = "bedrock-tfstate-897722710471"
    key          = "project-bedrock/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
  }
}