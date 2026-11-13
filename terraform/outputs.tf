# CloudDevOpsProject - Terraform Outputs

output "vpc_id" {
  description = "ID of the VPC"
  value       = module.network.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = module.network.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of private subnets"
  value       = module.network.private_subnet_ids
}

output "jenkins_public_ip" {
  description = "Public IP address of Jenkins EC2 instance"
  value       = module.server.jenkins_public_ip
}

output "jenkins_instance_id" {
  description = "Instance ID of Jenkins EC2"
  value       = module.server.jenkins_instance_id
}

output "jenkins_security_group_id" {
  description = "Security group ID for Jenkins"
  value       = module.server.jenkins_security_group_id
}

output "eks_cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "Endpoint URL of the EKS cluster"
  value       = module.eks.cluster_endpoint
}

output "eks_node_group_name" {
  description = "Name of the EKS worker node group"
  value       = module.eks.node_group_name
}

output "ecr_repository_url" {
  description = "URL of the ECR repository"
  value       = module.ecr.repository_url
}

output "account_id" {
  description = "AWS account ID"
  value       = data.aws_caller_identity.current.account_id
}

output "region" {
  description = "AWS region"
  value       = data.aws_region.current.name
}