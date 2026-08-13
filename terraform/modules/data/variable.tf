variable "project_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "vpc_cidr_block" {
  description = "Used to scope DB security group ingress to the VPC's CIDR (in addition to the node/pod SG)."
  type        = string
}

variable "eks_cluster_security_group_id" {
  description = "EKS cluster security group — DB ingress is restricted to this SG."
  type        = string
}

variable "db_instance_class" {
  type = string
}

variable "student_id" {
  description = "Unique suffix (student ID/name) for globally-unique resource names like the S3 assets bucket."
  type        = string
}

variable "budget_alert_email" {
  description = "Email address to receive AWS Budget alerts for this project."
  type        = string
}

variable "budget_limit_usd" {
  description = "Monthly budget threshold in USD."
  type        = number
  default     = 20
}
