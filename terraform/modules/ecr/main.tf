# ECR Module - Container Registry

variable "repository_name" {
  description = "Name of the ECR repository"
  type        = string
  default     = "ivolve-app"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

# ECR Repository
resource "aws_ecr_repository" "app" {
  name                 = "${var.environment}-${var.repository_name}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  lifecycle_policy {
    policy = jsonencode({
      rules = [
        {
          rulePriority = 1
          description = "Keep only last 10 images"
          selection = {
            tagStatus = "any"
            countType = "imageCountMoreThan"
            countNumber = 10
          }
          action = { type = "expire" }
        }
      ]
    })
  }

  tags = {
    Name        = "${var.environment}-ivolve-ecr"
    Environment = var.environment
  }
}

output "repository_name" {
  value = aws_ecr_repository.app.name
}

output "repository_url" {
  value = aws_ecr_repository.app.repository_url
}

output "repository_arn" {
  value = aws_ecr_repository.app.arn
}