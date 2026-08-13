variable "name" {
  description = "Name tag for the VPC (e.g. project-bedrock-vpc)."
  type        = string
}

variable "cidr_block" {
  type = string
}

variable "azs" {
  type        = list(string)
  description = "Availability zones to spread subnets across."
}

variable "cluster_name" {
  description = "EKS cluster name — used for the required kubernetes.io/cluster/<name> subnet tags."
  type        = string
}
