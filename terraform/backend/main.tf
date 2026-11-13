# Terraform Backend Configuration
# S3 bucket and DynamoDB table for state locking

terraform {
  backend "s3" {
    bucket         = "ivolve-terraform-state"
    key            = "cloud-devops-project/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "ivolve-terraform-lock"
  }
}

# AWS Provider Configuration
provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      Project  = "iVolve"
      Environment = var.environment
      ManagedBy = "Terraform"
    }
  }
}

# Data source for existing VPC (if using shared VPC)
data "aws_vpc" "default" {
  default = true
}