# -----------------------------------------------------------------------------
# Required root outputs (exam spec, Section 1). Keep this list to EXACTLY
# these five, non-sensitive values — `terraform output -json` ignores the
# `sensitive = true` flag, so anything secret must never land here.
# -----------------------------------------------------------------------------
output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_name" {
  value = module.eks.cluster_name
}

output "region" {
  value = var.aws_region
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "assets_bucket_name" {
  value = module.serverless.assets_bucket_name
}
