# Server Module - Jenkins EC2 & Security Groups

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"
}

variable "subnet_id" {
  description = "Subnet ID for Jenkins EC2 instance"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "jenkins_security_group_ids" {
  description = "List of security group IDs for Jenkins"
  type        = list(string)
  default     = []
}

variable "key_name" {
  description = "EC2 key pair name"
  type        = string
  default     = "ivolve-key"
}

variable "ami_id" {
  description = "AMI ID for Ubuntu"
  type        = string
  default     = ""
}

# Security Group for Jenkins
resource "aws_security_group" "jenkins" {
  name        = "${var.environment}-ivolve-jenkins-sg"
  description = "Security group for Jenkins server"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS access"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Jenkins UI access"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Jenkins agent port"
    from_port   = 50000
    to_port     = 50000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-ivolve-jenkins-sg"
    Environment = var.environment
  }
}

# Jenkins EC2 Instance
resource "aws_instance" "jenkins" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = concat(var.jenkins_security_group_ids, [aws_security_group.jenkins.id])
  key_name               = var.key_name

  root_block_device {
    volume_size = 50
    volume_type = "gp3"
    encrypted   = true
  }

  tags = {
    Name        = "${var.environment}-ivolve-jenkins"
    Environment = var.environment
    Role        = "jenkins-server"
  }

  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y openjdk-17-jre docker.io
              systemctl start docker
              systemctl enable docker
              usermod -aG docker ubuntu
              curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
              echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
              apt-get update -y
              apt-get install -y jenkins
              systemctl start jenkins
              systemctl enable jenkins
              EOF
}

output "jenkins_instance_id" {
  value = aws_instance.jenkins.id
}

output "jenkins_public_ip" {
  value = aws_instance.jenkins.public_ip
}

output "jenkins_private_ip" {
  value = aws_instance.jenkins.private_ip
}

output "jenkins_security_group_id" {
  value = aws_security_group.jenkins.id
}