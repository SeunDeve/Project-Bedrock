variable "aws_region" {
description = "AWS region for all resources. Fixed by exam spec."
type = string
default = "us-east-1"
}
variable "project_name" {
description = "Short name used to prefix/tag resources."
type = string
default = "project-bedrock"
}
variable "cluster_name" {
description = "EKS cluster name (fixed by exam spec)."
type = string
default = "project-bedrock-cluster"
}
variable "vpc_cidr" {
description = "CIDR block for the VPC."
type = string
default = "10.20.0.0/16"
}
variable "azs" {
description = "Availability zones to spread subnets across (min 2, per spec)."
type = list(string)
default = ["us-east-1a", "us-east-1b"]
}
variable "student_id" {
description = "Unique suffix (student ID/name) for globally-unique resource names like the S3 assets bucket."
type = string
# Intentionally no default — must be supplied via terraform.tfvars or -var
}
variable "eks_cluster_version" {
description = <<-EOT
Kubernetes version for EKS. Per exam spec: use the OLDEST actively-supported
version on the EKS version lifecycle table at deploy time (not end-of-life).
Check https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-versions.html
before applying and update this default accordingly.
EOT
type = string
default = "1.29" # <-- VERIFY against the current EKS lifecycle table before applying
}
variable "node_instance_types" {
description = "EC2 instance types for the EKS managed node group."
type = list(string)
default = ["t3.medium"]
}
variable "node_group_desired_size" {
type = number
default = 2
}
variable "node_group_min_size" {
type = number
default = 2
}
variable "node_group_max_size" {
type = number
default = 4
}
variable "db_instance_class" {
description = "RDS instance class — deliberately small per cost guardrails."
type = string
default = "db.t4g.micro"
}
variable "budget_alert_email" {
description = "Email address to receive AWS Budget alerts for this project."
type = string
}
variable "budget_limit_usd" {
  description = "Monthly budget threshold in USD."
  type        = number
  default     = 20
}

variable "enabled_cluster_log_types" {
  description = "EKS control plane log types to ship to CloudWatch."
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}