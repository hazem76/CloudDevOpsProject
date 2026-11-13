# CloudDevOpsProject - Terraform Root Module
# Orchestrates network, server, EKS, and ECR modules for AWS infrastructure

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# AWS Provider
provider "aws" {
  region = var.aws_region
}

# Data for AWS account
data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

# Backend Configuration
# Run: terraform init -backend-config="bucket=ivolve-terraform-state" \
#      -backend-config="key=cloud-devops-project/terraform.tfstate" \
#      -backend-config="region=us-east-1" \
#      -backend-config="dynamodb_table=ivolve-terraform-lock"

# Network Module
module "network" {
  source = "./modules/network"

  vpc_cidr           = var.vpc_cidr
  public_subnet_cidrs = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones = var.availability_zones
  environment        = var.environment
}

# Server Module (Jenkins EC2)
module "server" {
  source = "./modules/server"

  instance_type = var.instance_type
  subnet_id     = var.jenkins_subnet_id
  vpc_id        = module.network.vpc_id
  environment   = var.environment
  key_name      = var.key_name
  ami_id        = var.ami_id

  jenkins_security_group_ids = []
}

# EKS Module
module "eks" {
  source = "./modules/eks"

  cluster_name      = var.cluster_name
  cluster_version   = var.cluster_version
  vpc_id            = module.network.vpc_id
  subnet_ids        = module.network.private_subnet_ids
  security_group_ids = [module.server.jenkins_security_group_id]
  worker_instance_type = var.worker_instance_type
  worker_desired_size = var.worker_desired_size
  worker_min_size     = var.worker_min_size
  worker_max_size     = var.worker_max_size
  environment       = var.environment
}

# ECR Module
module "ecr" {
  source = "./modules/ecr"

  repository_name = var.ecr_repository_name
  environment     = var.environment
}

# Outputs
output "vpc_id" {
  value = module.network.vpc_id
}

output "public_subnet_ids" {
  value = module.network.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.network.private_subnet_ids
}

output "jenkins_public_ip" {
  value = module.server.jenkins_public_ip
}

output "jenkins_instance_id" {
  value = module.server.jenkins_instance_id
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "ecr_repository_url" {
  value = module.ecr.repository_url
}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "region" {
  value = data.aws_region.current.name
}