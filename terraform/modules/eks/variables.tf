variable "cluster_name" {
  type = string
}

variable "kubernetes_version" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "node_instance_types" {
  type = list(string)
}

variable "node_group_desired_size" {
  type = number
}

variable "node_group_min_size" {
  type = number
}

variable "node_group_max_size" {
  type = number
}

variable "enabled_cluster_log_types" {
  description = "EKS control plane log types to ship to CloudWatch."
  type        = list(string)
  default     = []
}
