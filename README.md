# Project Bedrock: AWS EKS Infrastructure

Terraform code for a production-style AWS platform running on Amazon EKS, built as part of my DevOps training at AltSchool Africa. The application deployment lives in [Project-Bedrock-App](https://github.com/SeunDeve/Project-Bedrock-App).

## What it provisions

- **Networking:** VPC with public and private subnets across two availability zones, an internet gateway, and a NAT gateway
- **Compute:** EKS cluster and managed node group, with OIDC and an IAM role for the AWS Load Balancer Controller
- **Data:** Amazon RDS for PostgreSQL and DynamoDB, with credentials stored in AWS Secrets Manager
- **Event processing:** S3 bucket that triggers a Python Lambda function when objects are uploaded
- **State:** versioned, encrypted S3 bucket for remote Terraform state

## Repository structure

```
terraform/
├── bootstrap/        # Remote state bucket
├── modules/
│   ├── vpc/          # Networking
│   ├── eks/          # Cluster, nodes, load balancer controller
│   └── data/         # RDS, DynamoDB, Secrets Manager, S3, Lambda
├── scripts/deploy.sh # Local init, plan, apply, destroy helper
└── main.tf
.github/workflows/    # Terraform CI/CD pipeline
```

## CI/CD

The GitHub Actions workflow runs on pull requests, pushes to `main`, and manual dispatch. It checks formatting, validates the code, and creates a plan. Apply and destroy are available as manual actions.

## Usage

Prerequisites: Terraform 1.11+, AWS CLI, and configured AWS credentials.

```bash
cd terraform
terraform init -backend-config="bucket=<state-bucket>" -backend-config="region=us-east-1"
terraform plan -var-file=terraform.tfvars -out=tfplan
terraform apply tfplan
```

`student_id` has no default, so set it in `terraform.tfvars`. Never commit that file.
