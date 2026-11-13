# CloudDevOpsProject - Enterprise CI/CD Pipeline

[![Build Status](https://img.shields.io/badge/build-passing-brightgreen)](https://github.com/hazem76/CloudDevOpsProject)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue)](LICENSE)
[![Terraform](https://img.shields.io/badge/terraform-v1.5+-purple)](https://www.terraform.io/)
[![Kubernetes](https://img.shields.io/badge/kubernetes-v1.28-blue)](https://kubernetes.io/)
[![Ansible](https://img.shields.io/badge/ansible-v2.12+-green)](https://www.ansible.com/)
[![Jenkins](https://img.shields.io/badge/jenkins-lts-red)](https://www.jenkins.io/)
[![Argo CD](https://img.shields.io/badge/argocd-gitops-orange)](https://argo-cd.readthedocs.io/)

## Overview

CloudDevOpsProject is a comprehensive enterprise-grade CI/CD pipeline implementation demonstrating modern DevOps practices including Infrastructure as Code (Terraform), Configuration Management (Ansible), Container Orchestration (Kubernetes), Continuous Integration/Continuous Deployment (Jenkins), and GitOps (Argo CD).

This project provisions and deploys the **iVolve microservices application** on AWS using a complete DevOps toolchain.

## Repository Structure

```
CloudDevOpsProject/
├── docker/                          # Local Docker test stack
│   ├── docker-compose.yml           # Multi-service Docker Compose with MySQL
│   └── Dockerfile                   # Base Node.js application image
├── terraform/                       # Infrastructure as Code (AWS)
│   ├── backend/                     # S3 state backend configuration
│   │   └── main.tf
│   ├── modules/                     # Reusable Terraform modules
│   │   ├── network/                 # VPC, subnets, IGW, NAT, NACLs
│   │   ├── server/                  # Jenkins EC2 instance
│   │   ├── eks/                     # EKS cluster with worker nodes
│   │   └── ecr/                     # Container registry
│   ├── main.tf                      # Root module orchestration
│   ├── variables.tf                 # Input variables
│   └── outputs.tf                   # Output values
├── ansible/                         # Configuration Management
│   ├── inventory/
│   │   └── aws_ec2.yml              # AWS dynamic inventory plugin
│   ├── roles/
│   │   ├── jenkins_node/            # Jenkins, Docker, Trivy setup
│   │   └── common/                  # Base system configuration
│   ├── playbook.yml                 # Main Ansible playbook
│   └── ansible.cfg                  # Ansible configuration
├── kubernetes/                      # Kubernetes Manifests
│   ├── namespace.yaml               # iVolve namespace
│   ├── configmap-secret.yaml        # ConfigMaps and Secrets
│   ├── storageclass.yaml            # Custom StorageClass
│   ├── database/
│   │   ├── statefulset.yaml         # MySQL StatefulSet
│   │   └── headless-service.yaml    # Headless service for MySQL
│   └── microservices/
│       ├── deployment-service-template.yaml  # Microservice deployment template
│       └── ingress.yaml             # ALB Ingress controller
├── jenkins/                         # CI Pipeline
│   ├── vars/                        # Jenkins Shared Library
│   │   ├── buildImage.groovy        # Application build step
│   │   ├── scanImage.groovy         # Trivy vulnerability scanner
│   │   ├── pushImage.groovy         # ECR image push
│   │   ├── deleteLocalImage.groovy  # Local image cleanup
│   │   └── updateManifestsAndPush.groovy  # GitOps manifest auto-commit
│   └── Jenkinsfile                  # Declarative pipeline definition
├── argocd/                          # GitOps with Argo CD
│   └── app.yaml                     # Argo CD Application manifest
└── README.md                        # This documentation
```

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         CloudDevOpsProject Architecture                  │
├─────────────────┬─────────────────┬─────────────────┬──────────────────┤
│   Terraform     │    Ansible      │   Jenkins CI    │   Argo CD         │
│   (IaC)         │   (Config Mgmt) │   (CI/CD)       │   (GitOps)        │
│                 │                 │                 │                   │
│ • VPC           │ • Java          │ • Build App     │ • App sync        │
│ • Subnets       │ • Jenkins LTS   │ • Docker build  • Auto-sync        │
│ • NAT Gateway   │ • Docker        │ • Trivy scan    • Self-heal        │
│ • EKS Cluster   │ • Trivy         │ • ECR push      • Prune            │
│ • Worker Nodes  │ • AWS inventory │ • Git commit    • Manifest watch   │
│ • ECR           │                 │ • K8s deploy    • Diff review       │
└─────────────────┴─────────────────┴─────────────────┴──────────────────┘
                              │
                              ▼
                    ┌─────────────────┐
                    │   AWS Cloud     │
                    │  • EKS Cluster  │
                    │  • EC2 (Jenkins)│
                    │  • ECR Registry │
                    │  • RDS MySQL    │
                    └─────────────────┘
```

## Core Components

### 1. Docker & Local Test Stack (`docker/`)
- **docker-compose.yml**: Multi-service setup integrating iVolve microservices with local MySQL
- **Dockerfile**: Multi-stage production-ready Node.js application image
- Networks: `ivolve-network` bridge network
- Volumes: `db_data` for MySQL persistence

### 2. Terraform Infrastructure (`terraform/`)
- **Network Module**: Multi-AZ VPC with public/private subnets, Internet Gateway, NAT Gateways, and Network ACLs
- **Server Module**: Jenkins EC2 instance with security groups (SSH 22, HTTP 80, HTTPS 443, Jenkins 8080, Agent 50000)
- **EKS Module**: EKS cluster with 2 worker nodes in private subnets, IAM roles and policies
- **ECR Module**: Private container registry with image scanning and lifecycle policies
- **Backend**: S3 bucket with DynamoDB state locking

### 3. Ansible Automation (`ansible/`)
- **Dynamic Inventory**: `aws_ec2.yml` plugin discovers EC2 instances tagged with `server:ivolve`
- **jenkins_node Role**: Installs Java 17, Jenkins LTS, Docker engine, and Trivy binary
- **common Role**: Base system configuration (packages, users, limits)
- **Playbook**: Orchestrates common and jenkins_node roles

### 4. Kubernetes Manifests (`kubernetes/`)
- **namespace.yaml**: `ivolve` namespace
- **configmap-secret.yaml**: Application configuration and secrets
- **storageclass.yaml**: Custom `ivolve-fast-storage` StorageClass (gp3, encrypted)
- **database/statefulset.yaml**: MySQL 8.0 StatefulSet with persistent storage
- **database/headless-service.yaml**: Headless service for MySQL StatefulSet
- **microservices/deployment-service-template.yaml**: Parameterized microservice deployment template
- **microservices/ingress.yaml**: ALB Ingress with TLS termination

### 5. Jenkins CI Pipeline (`jenkins/`)
- **Shared Library** (`vars/`): Modular Groovy scripts for build, scan, push, cleanup, and GitOps
- **Jenkinsfile**: Declarative pipeline with 8 stages:
  1. Checkout - SCM checkout
  2. Build App - Application build and tests
  3. Build Docker Image - Docker image build
  4. Scan Docker Image - Trivy vulnerability scan
  5. Push Image to ECR - Container registry push
  6. Delete Local Image - Storage cleanup
  7. Update Manifests and Push - GitOps manifest commit
  8. Deploy to Kubernetes - kubectl apply

### 6. Argo CD GitOps (`argocd/`)
- **app.yaml**: Argo CD Application monitoring `kubernetes/` directory
- Automated sync with prune and self-heal
- Manifest change detection and automatic deployment

## Prerequisites

### AWS Account
- AWS CLI configured with appropriate credentials
- IAM user with permissions for EC2, EKS, ECR, S3, DynamoDB, IAM, VPC
- AWS account ID and region

### Tools Required
| Tool | Minimum Version | Purpose |
|------|----------------|---------|
| Terraform | v1.5.0 | Infrastructure as Code |
| Ansible | v2.12+ | Configuration Management |
| kubectl | v1.28+ | Kubernetes CLI |
| AWS CLI | v2.x | AWS management |
| Docker | v20.10+ | Container runtime |
| Jenkins | LTS | CI/CD server |
| Argo CD | v2.8+ | GitOps |

### AWS IAM Permissions
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:*",
        "eks:*",
        "ecr:*",
        "s3:*",
        "dynamodb:*",
        "iam:*",
        "acm:*",
        "elasticloadbalancing:*"
      ],
      "Resource": "*"
    }
  ]
}
```

## Setup Instructions

### Phase 1: Infrastructure Provisioning (Terraform)

```bash
cd terraform/

# Initialize Terraform with backend
terraform init -backend-config="bucket=ivolve-terraform-state" \
               -backend-config="key=cloud-devops-project/terraform.tfstate" \
               -backend-config="region=us-east-1" \
               -backend-config="dynamodb_table=ivolve-terraform-lock"

# Review execution plan
terraform plan -var-file=terraform.tfvars

# Apply infrastructure
terraform apply -auto-approve

# Retrieve outputs
terraform output jenkins_public_ip
terraform output eks_cluster_name
terraform output ecr_repository_url
```

### Phase 2: Ansible Configuration Management

```bash
cd ansible/

# Configure AWS credentials
export AWS_ACCESS_KEY_ID=<your-key>
export AWS_SECRET_ACCESS_KEY=<your-secret>
export AWS_DEFAULT_REGION=us-east-1

# List discovered EC2 instances
ansible-inventory -i inventory/aws_ec2.yml --list

# Run playbook on Jenkins node
ansible-playbook -i inventory/aws_ec2.yml playbook.yml

# Verify Jenkins is accessible
curl -I http://<jenkins-ip>:8080
```

### Phase 3: Jenkins CI Pipeline

1. Install Jenkins on the provisioned EC2 instance
2. Configure credentials in Jenkins:
   - `dockerhub-credentials` - Docker Hub username/password
   - `ecr-credentials` - AWS access key/secret for ECR
   - `kubeconfig-credentials` - Kubernetes kubeconfig file
   - `git-credentials` - Git repository credentials
3. Install required plugins:
   - Pipeline, Docker Pipeline, Kubernetes CLI, Credentials Binding
4. Create a new Pipeline job:
   - Definition: Pipeline script from SCM
   - SCM: Git repository URL
   - Script Path: `jenkins/Jenkinsfile`
5. Run the pipeline

### Phase 4: Kubernetes Deployment

```bash
# Apply namespace
kubectl apply -f kubernetes/namespace.yaml

# Apply ConfigMaps and Secrets
kubectl apply -f kubernetes/configmap-secret.yaml

# Apply StorageClass
kubectl apply -f kubernetes/storageclass.yaml

# Apply database
kubectl apply -f kubernetes/database/

# Apply microservices
kubectl apply -f kubernetes/microservices/

# Verify deployment
kubectl get all -n ivolve
kubectl rollout status deployment/ivolve-app -n ivolve
```

### Phase 5: Argo CD GitOps

```bash
# Install Argo CD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Access Argo CD UI
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Get admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# Apply Argo CD Application
kubectl apply -f argocd/app.yaml

# Verify sync status
kubectl get application ivolve -n argocd
```

## Deployment Validation

### Verify All Components

| Component | Validation Command | Expected Result |
|-----------|-------------------|-----------------|
| EKS Cluster | `kubectl cluster-info` | Control plane running |
| Namespace | `kubectl get ns ivolve` | Active |
| MySQL Pod | `kubectl get pods -n ivolve -l app=ivolve-db` | Running |
| App Deployment | `kubectl get deploy -n ivolve` | Available replicas |
| Ingress | `kubectl get ingress -n ivolve` | ALB address |
| ECR Image | `aws ecr describe-images` | Image pushed |
| Argo CD Sync | `kubectl get app ivolve -n argocd` | Synced, Healthy |

### Test Application Access

```bash
# Port forward to test locally
kubectl port-forward -n ivolve svc/frontend-svc 3000:3000
curl http://localhost:3000/health

# Or access via Ingress (production)
curl https://<domain-name>/health
```

## Security Considerations

- All ECR images are scanned on push for vulnerabilities
- NACLs restrict inbound traffic to HTTP/HTTPS/SSH only
- EKS cluster uses private subnets for worker nodes
- Secrets are stored in Kubernetes Secrets (base64 encoded)
- For production, integrate with AWS Secrets Manager or HashiCorp Vault
- Enable TLS termination via ACM certificates
- Use IAM roles for service accounts (IRSA) instead of long-lived credentials

## Troubleshooting

| Issue | Solution |
|-------|---------|
| Terraform state lock | Check DynamoDB table for lock entries |
| Jenkins not starting | Check `/var/log/jenkins/jenkins.log` |
| Pods in CrashLoopBackOff | `kubectl logs <pod> -n ivolve` |
| ImagePullBackOff | Verify ECR credentials and image tag |
| Argo CD not syncing | Check webhook or polling interval |
| Trivy scan fails | Verify Docker socket permissions |

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/improvement`)
3. Commit changes (`git commit -m "feat: add new feature"`)
4. Push to branch (`git push origin feature/improvement`)
5. Open a Pull Request

## License

MIT License - see LICENSE file for details.

## Contact

DevOps Team: devops-team@ivolve.com