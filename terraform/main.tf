module "vpc" {
  source       = "./modules/vpc"
  name         = "project-bedrock-vpc"
  cidr_block   = var.vpc_cidr
  azs          = var.azs
  cluster_name = var.cluster_name
}

module "eks" {
  source                    = "./modules/eks"
  cluster_name              = var.cluster_name
  kubernetes_version        = var.eks_cluster_version
  vpc_id                    = module.vpc.vpc_id
  private_subnet_ids        = module.vpc.private_subnet_ids
  public_subnet_ids         = module.vpc.public_subnet_ids
  node_instance_types       = var.node_instance_types
  node_group_desired_size   = var.node_group_desired_size
  node_group_min_size       = var.node_group_min_size
  node_group_max_size       = var.node_group_max_size
  enabled_cluster_log_types = var.enabled_cluster_log_types
}

module "data" {
  source                        = "./modules/data"
  project_name                  = var.project_name
  vpc_id                        = module.vpc.vpc_id
  private_subnet_ids            = module.vpc.private_subnet_ids
  vpc_cidr_block                = module.vpc.vpc_cidr_block
  eks_cluster_security_group_id = module.eks.cluster_security_group_id
  db_instance_class             = var.db_instance_class
  student_id                    = var.student_id
  budget_alert_email            = var.budget_alert_email
  budget_limit_usd              = var.budget_limit_usd
}

# module "dev_access" { ... } # added in stage 4 (bedrock-dev-view IAM user)
# module "serverless" { ... } # added in stage 5 (S3 + Lambda)
